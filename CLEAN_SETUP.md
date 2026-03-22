# Clean Application Setup

This document describes how to set up a fresh EHR Portal application without running through all historical migration steps.

## Quick Start (Recommended for New Developers)

Instead of running all 40+ evolutionary setup steps, use the clean setup approach:

### 1. Prerequisites
```bash
# Ensure you have the required tools
ruby --version        # Ruby 4.0+
bundle --version      # Bundler
rails --version       # Rails 8.0+
node --version        # Node.js 20+
bun --version         # Bun (for Next.js development)
psql --version        # PostgreSQL
```

### 2. Database Setup
```bash
# Ensure PostgreSQL is running
brew services start postgresql

# Create databases
cd apps/ehr-api
bundle install
bin/rails db:create
bin/rails db:schema:load    # Load current schema (no migration evolution)
bin/rails db:seed           # Populate seed data
```

### 3. API Setup
```bash
cd apps/ehr-api

# Install dependencies
bundle install

# Setup environment
cp .env.example .env  # or create with: cp config/credentials.yml.enc config/master.key

# Run tests
bin/test

# Start development server
bin/rails s
```

### 4. Portal Setup
```bash
cd apps/ehr-portal

# Install dependencies
bun install

# Start development server
bin/dev
```

### 5. Verify

- API health check: `curl http://localhost:3000/api/up`
- Portal: Open `http://localhost:3001`
- GraphQL: `http://localhost:3000/graphql`
- Admin: `http://localhost:3000/admin`

## Key Difference: `db:schema:load` vs `db:migrate`

- **Old approach (evolutionary)**: Run `db:migrate` which executes all historical migrations
  - Time-consuming
  - Shows app evolution (Devise → Devise+JWT → Rodauth)
  - Useful for understanding development history

- **New approach (clean)**: Run `db:schema:load` which applies current schema directly
  - Fast (< 1 second)
  - Starts from current state (Rodauth + Rolify)
  - Recommended for new developers and CI/CD

## Authentication Architecture

The application uses **Rodauth for JWT authentication**:

- **Portal Users**: JWT tokens in Authorization header
  - Stateless authentication
  - Token TTL: 1 day
  - Signed with `secret_key_base`
  - Includes roles via Rolify

- **Admin Users**: Devise sessions
  - Session-based authentication
  - Isolated from portal users (separate AdminUser model)
  - HIPAA/PHI boundary enforcement

## Seed Data

The seed process creates:
- 3 portal users (patient, provider, staff) with password `password`
- 10 House MD patients with encounters
- Specialties and providers

## Environment Variables

```bash
# API
DB_HOST=localhost
DB_PORT=5432
NEXT_PUBLIC_API_URL=http://localhost:3000

# Portal
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## Troubleshooting

**Issue**: `PG::InsufficientPrivilege` error
- **Cause**: PostgreSQL user permissions
- **Solution**: `ALTER DATABASE ehr_api_development OWNER TO $(whoami);`

**Issue**: Cannot find token in response
- **Cause**: Login returns token in response body (not Authorization header)
- **Solution**: Ensure Portal uses `data.token` not `res.headers.get("Authorization")`

**Issue**: Tests failing with "frozen Array"
- **Cause**: RSpec environment pollution
- **Solution**: `bin/rails db:prepare` before running tests

## Historical Context (Optional)

If you want to understand the app's evolution, you can run the full step-by-step setup:

```bash
cd bin/steps
for step in *.sh; do
  bash "$step"
done
```

This will walk through:
1. Environment setup
2. Docker containers
3. Rails app creation
4. Sequential feature additions
5. Data modeling
6. UI implementation

This historical approach is useful for:
- Understanding architectural decisions
- Learning how features were integrated
- Reviewing commit history and PRs
- Maintaining reproducible development environments

## See Also

- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture and design
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development guidelines
- [Rodauth Documentation](https://rodauth.jeremyevans.net/) - JWT implementation
- [Rolify Documentation](https://github.com/RolifyCommunity/rolify) - Role management
