# Development Guide

Guide for developers working on the EHR Portal API and Portal applications.

## Table of Contents

1. [API Setup](#api-setup)
2. [Portal Setup](#portal-setup)
3. [Authentication](#authentication)
4. [Running Tests](#running-tests)
5. [Writing Tests](#writing-tests)
6. [GraphQL Queries](#graphql-queries)
7. [REST API](#rest-api)
8. [Debugging](#debugging)
9. [Common Tasks](#common-tasks)

## API Setup

### Prerequisites

```bash
ruby --version        # Ruby 3.3+
bundle --version      # Bundler
rails --version       # Rails 8.0+
psql --version        # PostgreSQL 13+
redis-cli --version   # Redis 6+
```

### First-Time Setup

```bash
cd apps/ehr-api

# Install dependencies
bundle install

# Setup database (quick, uses schema:load)
bin/rails db:create
bin/rails db:schema:load
bin/rails db:seed

# Verify setup
bin/rails db:version         # Should show schema version
bin/rails runner "puts User.count"  # Should show 3 users
```

### Environment

Create `.env.local` (git-ignored):

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ehr_api_development
DB_USER=scarver2

# Application
RAILS_ENV=development
RAILS_MASTER_KEY=<copy from config/master.key>

# Password hashing (optional)
BCRYPT_COST=12

# JWT (optional, uses defaults)
JWT_TTL=86400
JWT_ISSUER=ehr-portal-api

# GraphQL
GRAPHQL_PLAYGROUND=true  # Enable GraphQL IDE

# Redis (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# Email (for ActionMailer)
SMTP_ADDRESS=localhost
SMTP_PORT=1025
```

### Start Development Server

```bash
# Terminal 1: Rails API (port 3000)
cd apps/ehr-api
bin/rails s

# Terminal 2: Next.js Portal (port 3001)
cd apps/ehr-portal
bun dev

# Terminal 3: Sidekiq (background jobs)
cd apps/ehr-api
bundle exec sidekiq -c 5

# Terminal 4: Redis (if not using Homebrew services)
redis-server
```

### Check Health

```bash
# API
curl http://localhost:3000/api/up
# Returns: { status: "ok" }

# GraphQL
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { types { name } } }"}'

# Portal
open http://localhost:3001

# Admin
open http://localhost:3000/admin
```

## Portal Setup

### Prerequisites

```bash
node --version        # Node.js 18+
bun --version         # Bun 1.0+
```

### First-Time Setup

```bash
cd apps/ehr-portal

# Install dependencies
bun install

# Create environment file
cp .env.example .env.local

# Start development server
bun dev
```

### Environment

Create `apps/ehr-portal/.env.local`:

```bash
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## Authentication

### Login as Portal User

```bash
# 1. Get token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "provider@ehr.local",
      "password": "password"
    }
  }'

# Returns:
# {
#   "user": { "id": 1, "email": "provider@ehr.local", "roles": ["provider"] },
#   "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
# }

# 2. Use token in subsequent requests
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/v1/users/1
```

### Login as Admin User

```bash
# 1. Visit /admin
open http://localhost:3000/admin

# 2. Login with:
# Email: admin@ehr.local
# Password: change_me!  (seed default)

# 3. You'll see ActiveAdmin dashboard
```

### Test Users (From Seed)

```bash
# Provider (can access all clinical data)
Email:    provider@ehr.local
Password: password
Roles:    [:provider]

# Staff (can access scheduling/billing)
Email:    staff@ehr.local
Password: password
Roles:    [:staff]

# Patient (can only access own records)
Email:    patient@ehr.local
Password: password
Roles:    [:patient]

# Admin (only for admin dashboard)
Email:    admin@ehr.local
Password: change_me!
```

### Generate Test Token (Programmatically)

```ruby
# In Rails console
user = User.find_by(email: "provider@ehr.local")
token = User.generate_jwt_token(user)

puts "Authorization: Bearer #{token}"
```

## Running Tests

### API Tests

```bash
cd apps/ehr-api

# Run all tests
bin/test

# Run specific file
bin/test spec/requests/api/v1/auth/sessions_spec.rb

# Run with pattern
bin/test --pattern auth

# Run with verbose output
bin/test --verbose

# Run with seed (for reproducibility)
bin/test --seed 12345

# Generate coverage report
COVERAGE=true bin/test
open coverage/index.html
```

### Portal Tests

```bash
cd apps/ehr-portal

# Unit/integration tests (Vitest)
bun test

# E2E tests (Playwright)
bun test:e2e

# Watch mode
bun test --watch

# Coverage
bun test --coverage
open coverage/index.html
```

### Linting

```bash
cd apps/ehr-api
bin/lint          # Run RuboCop
bin/lint --fix    # Auto-fix issues

cd apps/ehr-portal
bun run lint      # Run ESLint
bun run lint:fix  # Auto-fix issues
```

### Type Checking

```bash
# API (RBS)
cd apps/ehr-api
bin/typecheck

# Portal (TypeScript)
cd apps/ehr-portal
bun run typecheck
```

## Writing Tests

### API Request Spec Template

```ruby
# spec/requests/api/v1/patients_spec.rb
require 'rails_helper'

describe 'Patients API' do
  describe 'GET /api/v1/patients/:id' do
    let(:patient) { create(:patient) }
    let(:provider) { create(:user, :provider) }
    let(:token) { login_user(provider) }

    context 'when authenticated' do
      it 'returns the patient' do
        get "/api/v1/patients/#{patient.id}",
            headers: { 'Authorization': "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(patient.id)
      end
    end

    context 'when not authenticated' do
      it 'returns 401' do
        get "/api/v1/patients/#{patient.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

# spec/support/auth_helper.rb (already provided)
def login_user(user, password = "password")
  post "/api/v1/auth/login", params: {
    user: { email: user.email, password: password }
  }
  JSON.parse(response.body)["token"]
end
```

### GraphQL Query Spec Template

```ruby
# spec/graphql/queries/current_user_spec.rb
require 'rails_helper'

describe 'Query.currentUser' do
  let(:user) { create(:user, :provider) }

  it 'returns current user when authenticated' do
    # Create context with authenticated user
    context = { current_user: user }

    result = EhrApiSchema.execute(
      query_string,
      context: context
    )

    expect(result['data']['currentUser']['id']).to eq(user.id.to_s)
  end

  it 'returns null when not authenticated' do
    context = { current_user: nil }

    result = EhrApiSchema.execute(
      query_string,
      context: context
    )

    expect(result['data']['currentUser']).to be_nil
  end

  private

  def query_string
    <<~GQL
      query {
        currentUser {
          id
          email
          roles { name }
        }
      }
    GQL
  end
end
```

### Portal Component Test Template

```typescript
// apps/ehr-portal/src/components/__tests__/profile-card.test.tsx
import { render, screen } from "@testing-library/react";
import { ProfileCard } from "../profile-card";

describe("ProfileCard", () => {
  it("renders user profile", () => {
    const user = { id: 1, email: "provider@ehr.local", roles: ["provider"] };

    render(<ProfileCard user={user} />);

    expect(screen.getByText("provider@ehr.local")).toBeInTheDocument();
    expect(screen.getByText("provider")).toBeInTheDocument();
  });

  it("shows loading state", () => {
    render(<ProfileCard user={null} loading={true} />);

    expect(screen.getByTestId("loading-spinner")).toBeInTheDocument();
  });
});
```

## GraphQL Queries

### Query: Current User

```graphql
query CurrentUser {
  currentUser {
    id
    email
    roles {
      name
    }
    provider {
      id
      name
    }
    patient {
      id
      firstName
      lastName
    }
  }
}
```

Test it:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "query": "query { currentUser { id email roles { name } } }"
  }'
```

### Query: Patients

```graphql
query Patients($first: Int, $after: String) {
  patients(first: $first, after: $after) {
    edges {
      node {
        id
        firstName
        lastName
        dateOfBirth
        encounters {
          id
          visitDate
          reason
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

Test it:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "query": "query Patients { patients(first: 10) { edges { node { id firstName } } } }"
  }'
```

### Mutation: Create Patient

```graphql
mutation CreatePatient($input: CreatePatientInput!) {
  createPatient(input: $input) {
    patient {
      id
      firstName
      lastName
    }
    errors {
      field
      message
    }
  }
}
```

Test it (with variables):
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "query": "mutation CreatePatient($input: CreatePatientInput!) { createPatient(input: $input) { patient { id } } }",
    "variables": {
      "input": {
        "firstName": "Jane",
        "lastName": "Doe",
        "dateOfBirth": "1990-01-01"
      }
    }
  }'
```

## REST API

### GET /api/v1/users/:id

Fetch a specific user:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/v1/users/1
```

Response:
```json
{
  "id": 1,
  "email": "provider@ehr.local",
  "roles": ["provider"],
  "provider_id": 1
}
```

### POST /api/v1/auth/login

Login with email/password:

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "provider@ehr.local",
      "password": "password"
    }
  }'
```

Response:
```json
{
  "user": {
    "id": 1,
    "email": "provider@ehr.local",
    "roles": ["provider"]
  },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### DELETE /api/v1/auth/logout

Logout (optional — tokens expire automatically):

```bash
curl -X DELETE http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer $TOKEN"
```

## Debugging

### Rails Console

```bash
cd apps/ehr-api
rails console

# Find user
> user = User.find_by(email: "provider@ehr.local")
> user.email
> user.roles.pluck(:name)  # ["provider"]
> user.account.valid_password?("password")  # true

# Generate token manually
> secret = Rails.application.credentials.secret_key_base
> payload = { sub: user.id, exp: 1.day.from_now.to_i, iat: Time.now.to_i, iss: "ehr-portal-api" }
> token = JWT.encode(payload, secret, "HS256")
> puts token

# Decode token
> decoded = JWT.decode(token, secret, true, { algorithm: "HS256" })
> puts decoded.first

# Check account status
> user.account.status  # "verified"
```

### GraphQL Playground

Visit `http://localhost:3000/graphql` for interactive GraphQL IDE:

```graphql
query {
  __schema {
    types {
      name
    }
  }
}
```

### Browser DevTools

**Portal Network Tab:**
- Watch JWT token in Authorization header
- Monitor GraphQL queries/mutations
- Check response status codes

**Browser Storage:**
- localStorage: `auth_token`, `current_user`
- Verify token format (header.payload.signature)

### Log Files

```bash
# API logs
tail -f log/development.log

# Portal logs (in browser console)
F12 → Console tab

# Sidekiq logs
tail -f log/sidekiq.log

# PostgreSQL logs
tail -f /usr/local/var/log/postgres.log
```

### Debugging Tests

```bash
# Run single test with output
bin/test spec/requests/api/v1/auth/sessions_spec.rb:12

# Run with pry debugger
# Add `binding.pry` in test, then:
bin/test --no-fail-fast

# Check test database state
rails console --environment=test
> User.count

# Reset test database
bin/rails db:test:prepare
```

## Common Tasks

### Create a New User

```ruby
# In Rails console or seed file
user = User.create!(email: "newuser@ehr.local")
user.add_role(:provider)
user.create_account!(password: "temporary_password")
```

### Add Role to Existing User

```ruby
user = User.find_by(email: "provider@ehr.local")
user.add_role(:patient)  # Now has both :provider and :patient
```

### Change User Password

```ruby
user = User.find_by(email: "provider@ehr.local")
user.account.update!(password_hash: BCrypt::Password.create("new_password"))
```

### Check User Roles

```ruby
user = User.find_by(email: "provider@ehr.local")
user.roles.pluck(:name)         # ["provider"]
user.has_role?(:provider)       # true
user.has_role?(:patient)        # false
```

### Create Admin User

```ruby
# In Rails console
AdminUser.create!(
  email: "admin@ehr.local",
  password: "secure_password"
)
```

### View All Routes

```bash
cd apps/ehr-api
rails routes | grep -E "(auth|api)"
```

### Clear Cache

```bash
# Rails cache
rails cache:clear

# Redis
redis-cli FLUSHDB

# Session cookies
# (Browser dev tools → Application → Storage → Clear)
```

### Run Database Migration

```bash
# Create migration
rails generate migration AddFieldToUsers

# Run pending migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Rollback to specific version
rails db:migrate VERSION=20260321000000
```

### Deploy Changes

See [CONTRIBUTING.md](./CONTRIBUTING.md) for Git workflow and PR guidelines.

## Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [GraphQL Ruby](https://graphql-ruby.org/)
- [Rodauth Documentation](https://rodauth.jeremyevans.net/)
- [Rolify Documentation](https://github.com/RolifyCommunity/rolify)
- [Next.js Documentation](https://nextjs.org/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [RSpec Documentation](https://rspec.info/)
- [Playwright Documentation](https://playwright.dev/)
