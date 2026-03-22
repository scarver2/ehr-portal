# Authentication Architecture

This document describes the authentication system used in the EHR Portal application.

## Overview

The EHR Portal uses a **dual authentication model** to strictly separate clinical user access from administrative access:

1. **Portal/API Users**: JWT tokens (Rodauth) for stateless API authentication
2. **Admin Users**: Devise sessions for administrative dashboard access

This separation ensures that:
- Admin accounts can never access patient/clinical data via the API
- Portal users cannot access the admin interface
- Each system uses authentication best practices for its use case

## Portal Users: Rodauth JWT Authentication

### Architecture

[Rodauth](https://rodauth.jeremyevans.net/) is a modern authentication framework built for JWT and API-first applications. Portal users authenticate via JWT tokens.

```
┌─────────────────┐
│ Next.js Portal  │
│ (React Client)  │
└────────┬────────┘
         │ POST /api/v1/auth/login
         │ { email, password }
         │
         ↓
┌─────────────────┐       ┌──────────────┐
│  Rails API      │──────→│  PostgreSQL  │
│  GraphQL/REST   │       │   (Account)  │
│                 │       └──────────────┘
└────────┬────────┘
         │ Returns: { user, token }
         │ token = JWT(sub: user_id, exp: now+1d)
         │
         ↓
┌─────────────────┐
│ Portal Storage  │
│ (localStorage)  │
└─────────────────┘
```

### Token Format

Tokens are HMAC-SHA256 signed JWTs:

```
Header:  { "typ": "JWT", "alg": "HS256" }
Payload: { "sub": 42, "exp": 1711047600, "iat": 1710961200, "iss": "ehr-portal-api" }
Signature: HMAC-SHA256(header.payload, Rails.application.credentials.secret_key_base)
```

**Token Fields:**
- `sub` (subject): User ID
- `exp` (expiration): Unix timestamp (1 day after issue)
- `iat` (issued at): Unix timestamp
- `iss` (issuer): "ehr-portal-api"

### Request Flow

```
1. Client POST /api/v1/auth/login
   { email: "provider@ehr.local", password: "password123" }

2. Server validates email/password against Account.password_hash (bcrypt)

3. If valid, generates JWT:
   secret = Rails.application.credentials.secret_key_base
   token = JWT.encode(
     { sub: user.id, exp: 1.day.from_now.to_i, iat: Time.now.to_i, iss: "ehr-portal-api" },
     secret,
     "HS256"
   )

4. Returns: { user: { id, email, roles }, token: "eyJ..." }

5. Client stores token in localStorage

6. Client sends token in Authorization header:
   Authorization: Bearer eyJ...

7. For GraphQL/REST requests:
   - Extract Authorization header
   - Verify JWT signature and expiration
   - Load User by decoded "sub" (user ID)
   - Set context.current_user for resolvers

8. Logout: Client clears localStorage (stateless, no server action needed)
```

### Account Model

The `Account` model manages password hashing and status:

```ruby
class Account < ApplicationRecord
  belongs_to :user

  # Attributes
  attr_accessor :email, :password_hash, :status

  # Status values: "verified", "unverified", "closed"
  # Default: "verified" (all users created via seed are verified)

  # Password validation
  def valid_password?(password)
    BCrypt::Password.new(password_hash) == password
  end
end
```

### Password Hashing

Passwords are hashed with **bcrypt** (industry standard):

```ruby
# In Account
cost_factor = ENV["BCRYPT_COST"].to_i || (Rails.env.test? ? 1 : 12)
self.password_hash = BCrypt::Password.create(password, cost: cost_factor)

# Verification
BCrypt::Password.new(stored_hash) == user_input_password
```

**Cost Factors:**
- **Test**: 1 (fast)
- **Development**: 12 (default)
- **Production**: 12 (default, ~250ms per hash)

## Admin Users: Devise Sessions

### Architecture

Admin accounts use [Devise](https://github.com/heartcomers/devise) with session-based authentication (traditional Rails):

```
┌─────────────────┐
│ ActiveAdmin     │
│ (Admin Browser) │
└────────┬────────┘
         │ POST /admin/login
         │ { email, password }
         │
         ↓
┌──────────────────────┐
│ Rails Session Mgmt   │
│ (Warden + Devise)    │
└────────┬─────────────┘
         │ Creates encrypted session
         │ Sets secure HTTP-only cookie
         │
         ↓
┌──────────────────────┐
│ Browser Cookie       │
│ (HTTP-only, secure)  │
└──────────────────────┘
```

### AdminUser Model

```ruby
class AdminUser < ApplicationRecord
  devise :database_authenticatable, :validatable, :rememberable

  # Email + encrypted_password only
  # No roles (all AdminUsers are admin)
end
```

### Key Differences from Portal Users

| Portal User | Admin User |
|---|---|
| Uses: **Rodauth JWT** | Uses: **Devise Sessions** |
| Stateless (token in Authorization header) | Stateful (session in HTTP-only cookie) |
| Can access: GraphQL API, REST endpoints | Can access: /admin dashboard, ActiveAdmin |
| Roles via Rolify (dynamic) | No roles (binary: admin or not) |
| Password stored in Account table | Password stored in AdminUser table |
| Login returns JWT in response body | Login returns encrypted session cookie |
| No logout needed (token expires) | Logout via /admin/logout |

## Role-Based Access Control (RBAC)

Portal users have flexible role assignment via [Rolify](https://github.com/RolifyCommunity/rolify):

### Available Roles

- `:patient` — Clinical patient
- `:provider` — Healthcare provider (MD, RN, etc.)
- `:staff` — Administrative staff (scheduler, billing, etc.)

### Usage

```ruby
user = User.find(1)

# Assign role
user.add_role(:provider)
user.add_role(:staff)

# Check role
user.has_role?(:provider)    # true
user.has_role?(:patient)      # false

# Remove role
user.remove_role(:provider)

# Get all roles
user.roles  # [Role(name: "provider"), Role(name: "staff")]
```

### Validation

Users must have at least one role:

```ruby
class User < ApplicationRecord
  validate :has_at_least_one_role

  private
  def has_at_least_one_role
    errors.add(:base, "User must have at least one role") if roles.empty?
  end
end
```

## GraphQL Authentication

The GraphQL controller uses JWT to authenticate requests:

```ruby
class GraphqlController < ActionController::API
  include ActionController::Cookies
  protect_from_forgery with: :null_session
  before_action :authenticate_graphql_user!

  private

  def current_user
    @current_user ||= load_user_from_jwt_token || load_admin_from_session
  end

  def load_user_from_jwt_token
    token = extract_token_from_request
    return nil unless token

    begin
      secret = Rails.application.credentials.secret_key_base
      payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first
      user_id = payload["sub"]&.to_i
      user = User.find_by(id: user_id)
      user if user && user.account&.status == "verified"
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end

  def load_admin_from_session
    current_admin_user if defined?(current_admin_user)
  end

  def extract_token_from_request
    request.headers["Authorization"]&.sub(/\ABearer\s+/, "")
  end

  def authenticate_graphql_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end
end
```

### GraphQL Queries

All GraphQL queries check authorization via the resolver context:

```ruby
class Types::QueryType < Types::BaseObject
  field :current_user, Types::UserType, null: true

  def current_user
    context[:current_user]
  end

  field :patient, Types::PatientType, null: true do
    argument :id, ID, required: true
  end

  def patient(id:)
    return nil unless context[:current_user]
    Patient.find_by(id: id)
  end
end
```

## Portal Login & Logout

### Login Flow

**Frontend** (`apps/ehr-portal/src/lib/auth.ts`):

```typescript
async function login(email: string, password: string) {
  const response = await fetch(`${apiUrl}/api/v1/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ user: { email, password } })
  });

  const data = await response.json();
  localStorage.setItem("auth_token", data.token);
  localStorage.setItem("current_user", JSON.stringify(data.user));
  return data.user;
}
```

**Backend** (`apps/ehr-api/app/controllers/api/v1/auth/sessions_controller.rb`):

```ruby
class Api::V1::Auth::SessionsController < Api::ApplicationController
  def login
    user = User.where(email: user_params[:email]).first
    if user&.account&.valid_password?(user_params[:password])
      token = generate_jwt_token(user)
      render json: {
        user: { id: user.id, email: user.email, roles: user.roles.pluck(:name) },
        token: token
      }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def generate_jwt_token(user)
    secret = Rails.application.credentials.secret_key_base
    payload = {
      sub: user.id,
      exp: 1.day.from_now.to_i,
      iat: Time.now.to_i,
      iss: "ehr-portal-api"
    }
    JWT.encode(payload, secret, "HS256")
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
```

### Logout Flow

**Frontend** (`apps/ehr-portal/src/lib/auth/logout.ts`):

```typescript
async function logout() {
  // Optional: notify server (no token invalidation needed; token expires automatically)
  await fetch(`${apiUrl}/api/v1/auth/logout`, {
    method: "DELETE",
    headers: { "Authorization": `Bearer ${localStorage.getItem("auth_token")}` }
  });

  // Clear client state
  localStorage.removeItem("auth_token");
  localStorage.removeItem("current_user");
  router.push("/login");
}
```

Since tokens are stateless, there's no server-side logout needed. The token simply expires after 1 day.

## Development & Testing

### Seed Data

The seed process creates test users with password `password`:

```bash
# apps/ehr-api/db/seeds/0_users.rb
User.find_or_create_by(email: "provider@ehr.local") do |user|
  user.add_role(:provider)
  user.create_account!(password: "password")
end
```

### Test Helpers

Use the provided auth helpers in specs:

```ruby
# In spec/support/auth_helper.rb
def login_user(user, password = "password")
  post "/api/v1/auth/login", params: {
    user: { email: user.email, password: password }
  }
  JSON.parse(response.body)["token"]
end

# In tests
it "returns user data for authenticated requests" do
  user = create(:user, :provider)
  token = login_user(user)

  get "/api/v1/users/#{user.id}", headers: { "Authorization": "Bearer #{token}" }
  expect(response).to have_http_status(:ok)
end
```

### Token Expiration in Tests

Tokens expire after 1 day in development/production, but can be adjusted in specs:

```ruby
# config/initializers/rodauth.rb
Rodauth.configure do
  jwt_ttl = ENV["JWT_TTL"]&.to_i || 86400  # 1 day default
end

# In .env.test
JWT_TTL=3600  # 1 hour for tests (if needed)
```

## Environment Variables

Required environment variables for authentication:

```bash
# Database (for Account table)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ehr_api_development
DB_USER=scarver2

# JWT signing
# Uses Rails.application.credentials.secret_key_base by default
# Can override (not recommended):
# JWT_SECRET=<base64-secret>

# Password hashing
BCRYPT_COST=12  # Default, can lower to 1 for tests

# Token expiration (seconds)
JWT_TTL=86400  # 1 day default

# Issuer
JWT_ISSUER=ehr-portal-api  # Default
```

## Security Considerations

### 1. Token Storage

**Frontend storage**:
- `localStorage` for token (accessible to JavaScript, subject to XSS)
- HTTP-only cookie alternative planned for future versions

**Mitigation**:
- Use Content Security Policy (CSP) headers
- Sanitize user input to prevent XSS
- Keep dependencies updated

### 2. HTTPS Only

Always use HTTPS in production:
- Tokens are passed in Authorization header
- Session cookies are secure + HTTP-only
- Prevents man-in-the-middle attacks

### 3. Password Hashing

- bcrypt with cost factor 12 (default)
- ~250ms per hash (prevents brute force)
- Cost factor 1 in tests (fast)

### 4. Token Expiration

- 1 day token lifetime
- No refresh token mechanism (stateless design)
- Users re-login for fresh tokens

### 5. Scope Separation

- Portal users (JWT) cannot access admin endpoints
- Admin users (sessions) cannot call API endpoints
- /admin routes require AdminUser session
- /api routes require valid JWT

### 6. CORS & CSRF

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3001', 'example.com'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete]
  end
end

# config/initializers/csrf_meta_tags.rb
protect_from_forgery with: :null_session  # For API + GraphQL
```

## Migration from Devise-JWT

If you're upgrading from the old Devise+JWT system:

1. **Users can still login** — existing passwords work with new Rodauth system
2. **Token format changed** — clients must update authorization header usage
3. **No breaking changes for GraphQL** — token still goes in Authorization header
4. **No manual migration** — see [MIGRATION.md](./MIGRATION.md)

See [MIGRATION.md](./MIGRATION.md) for detailed upgrade instructions.

## References

- [Rodauth Documentation](https://rodauth.jeremyevans.net/)
- [JSON Web Token (JWT) RFC 7519](https://tools.ietf.org/html/rfc7519)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [bcrypt Documentation](https://en.wikipedia.org/wiki/Bcrypt)
- [Rolify Documentation](https://github.com/RolifyCommunity/rolify)
- [Devise Documentation](https://github.com/heartcomers/devise)
