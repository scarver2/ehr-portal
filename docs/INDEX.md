# Documentation Index

Complete guide to EHR Portal documentation.

## Quick Start

**New developer?** Start here:
1. [CLEAN_SETUP.md](../CLEAN_SETUP.md) — Fast setup in ~5 minutes
2. [DEVELOPMENT.md](./DEVELOPMENT.md) — Common development tasks

## Architecture & Design

- **[AUTHENTICATION.md](./AUTHENTICATION.md)** — Complete auth system documentation
  - Rodauth JWT architecture for portal users
  - Devise sessions for admin users
  - Role-based access control (RBAC) with Rolify
  - Token formats, security, and best practices

- **[RODAUTH_MIGRATION_SUMMARY.md](./RODAUTH_MIGRATION_SUMMARY.md)** — Migration overview
  - What changed and why
  - Before/after comparisons
  - Performance & security improvements
  - Complete file list of changes

## Getting Started

- **[CLEAN_SETUP.md](../CLEAN_SETUP.md)** — Application setup
  - Prerequisites and installation
  - Database setup using `db:schema:load` (fast)
  - Verification steps
  - Troubleshooting common issues

- **[DEVELOPMENT.md](./DEVELOPMENT.md)** — Development guide
  - API setup and environment configuration
  - Portal setup with Next.js
  - Running and writing tests
  - GraphQL and REST API examples
  - Debugging techniques
  - Common development tasks

## Implementation Details

- **[AUTHENTICATION.md](./AUTHENTICATION.md)** — Auth system deep dive
  - JWT token structure and validation
  - Rodauth configuration
  - Account model and password hashing
  - GraphQL authentication middleware
  - Login/logout flows
  - Environment variables
  - Security considerations

- **[DEVELOPMENT.md](./DEVELOPMENT.md)** — API documentation
  - REST API endpoints
  - GraphQL queries and mutations
  - Authentication examples
  - Test patterns
  - Debugging tips

## Deployment & Migration

- **[MIGRATION.md](./MIGRATION.md)** — Upgrade from old system
  - What changed (breaking and non-breaking)
  - Code migration examples
  - Database migration details
  - Troubleshooting migration issues
  - Portal client code updates
  - Performance impact

- **[DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)** — Production deployment
  - Pre-deployment preparation
  - Step-by-step deployment process
  - Post-deployment verification
  - Monitoring and alerts
  - Rollback procedures
  - Communication templates

## Reference

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — System design (if exists)
  - Component relationships
  - Data flows
  - Module dependencies
  - Scalability considerations

- **[CONTRIBUTING.md](./CONTRIBUTING.md)** — Development guidelines (if exists)
  - Git workflow
  - Code style
  - Testing requirements
  - PR process

## Directory Structure

```
ehr-portal/
├── README.md                          # Project overview
├── CLEAN_SETUP.md                     # Quick setup guide
├── docs/
│   ├── INDEX.md                       # ← You are here
│   ├── AUTHENTICATION.md              # Auth architecture
│   ├── RODAUTH_MIGRATION_SUMMARY.md   # Migration overview
│   ├── MIGRATION.md                   # Upgrade guide
│   ├── DEVELOPMENT.md                 # Dev guide & examples
│   ├── DEPLOYMENT_CHECKLIST.md        # Production deployment
│   ├── ARCHITECTURE.md                # System design
│   ├── CONTRIBUTING.md                # Development guidelines
│   ├── notes.md                       # Developer notes
│   ├── roadmap.md                     # Project roadmap
│   └── todo.md                        # TODO items
├── apps/ehr-api/
│   ├── README.md                      # API-specific docs
│   ├── config/
│   │   ├── initializers/
│   │   │   ├── devise.rb              # Devise config (AdminUser only)
│   │   │   ├── active_admin.rb        # ActiveAdmin config
│   │   │   └── cors.rb                # CORS config
│   │   └── routes.rb                  # Routes (devise_for :admin_users)
│   ├── app/models/
│   │   ├── user.rb                    # Portal user (Rodauth + Rolify)
│   │   ├── account.rb                 # Password storage (Rodauth)
│   │   ├── admin_user.rb              # Admin user (Devise sessions)
│   │   └── role.rb                    # Rolify roles
│   ├── app/controllers/
│   │   ├── graphql_controller.rb      # JWT auth for GraphQL
│   │   ├── api/v1/auth/
│   │   │   └── sessions_controller.rb # Login/logout endpoints
│   │   └── application_controller.rb  # Admin checks
│   ├── db/
│   │   ├── schema.rb                  # Current schema
│   │   ├── migrate/
│   │   │   ├── *_create_accounts.rb           # Rodauth tables
│   │   │   ├── *_create_rolify_tables.rb      # Rolify tables
│   │   │   └── *_migrate_users_to_rodauth.rb  # Data migration
│   │   └── seeds/
│   │       ├── 0_users.rb             # User seeds (with Rodauth)
│   │       └── 7_patients.rb          # Patient seeds
│   └── spec/
│       ├── support/auth_helper.rb     # JWT auth helpers
│       ├── requests/
│       │   └── api/v1/auth/
│       │       └── sessions_spec.rb   # Auth tests
│       └── graphql/
│           └── queries/
│               └── *_spec.rb          # GraphQL tests
├── apps/ehr-portal/
│   ├── src/
│   │   ├── lib/
│   │   │   ├── auth.ts                # Login/logout functions
│   │   │   └── auth/
│   │   │       └── logout.ts          # Logout helper
│   │   ├── context/
│   │   │   └── auth-context.tsx       # AuthProvider (token storage)
│   │   ├── components/
│   │   │   ├── protected.tsx          # Protected route wrapper
│   │   │   ├── logout-button.tsx      # Logout button
│   │   │   └── sidebar.tsx            # Navigation
│   │   └── app/
│   │       ├── login/
│   │       │   └── page.tsx           # Login page
│   │       └── page.tsx               # Home page
│   └── __tests__/
│       ├── auth.test.ts               # Auth tests
│       └── logout.test.ts             # Logout tests
└── bin/
    ├── steps/
    │   └── 10_ruby-on-rails-clean.sh  # Clean setup script
    ├── health                         # Health check script
    └── ...
```

## How to Use This Documentation

### For Understanding the System

1. Start with [README.md](../README.md) for overview
2. Read [AUTHENTICATION.md](./AUTHENTICATION.md) for architecture
3. Review [RODAUTH_MIGRATION_SUMMARY.md](./RODAUTH_MIGRATION_SUMMARY.md) for context

### For Development

1. Use [CLEAN_SETUP.md](../CLEAN_SETUP.md) to set up locally
2. Reference [DEVELOPMENT.md](./DEVELOPMENT.md) for common tasks
3. Use inline code comments for specific implementation details

### For Deployment

1. Follow [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) step-by-step
2. Have [MIGRATION.md](./MIGRATION.md) available for troubleshooting
3. Use [AUTHENTICATION.md](./AUTHENTICATION.md) for debugging auth issues

### For Upgrading

1. Read [MIGRATION.md](./MIGRATION.md) from start to finish
2. Follow migration steps carefully
3. Run provided troubleshooting steps if issues arise

## Key Documentation by Topic

### Authentication
- [AUTHENTICATION.md](./AUTHENTICATION.md) — Complete architecture
- [DEVELOPMENT.md](./DEVELOPMENT.md#authentication) — Auth examples
- [MIGRATION.md](./MIGRATION.md#code-migration-examples) — Before/after code

### Testing
- [DEVELOPMENT.md](./DEVELOPMENT.md#writing-tests) — Test templates
- [MIGRATION.md](./MIGRATION.md#spec-tests) — Test improvements

### Deployment
- [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) — Full process
- [CLEAN_SETUP.md](../CLEAN_SETUP.md#key-difference-dbschemaloadvs-dbmigrate) — Migration vs schema:load

### Troubleshooting
- [CLEAN_SETUP.md](../CLEAN_SETUP.md#troubleshooting) — Setup issues
- [MIGRATION.md](./MIGRATION.md#troubleshooting-migration) — Migration issues
- [DEVELOPMENT.md](./DEVELOPMENT.md#debugging) — Debugging techniques

### API Reference
- [DEVELOPMENT.md](./DEVELOPMENT.md#graphql-queries) — GraphQL queries
- [DEVELOPMENT.md](./DEVELOPMENT.md#rest-api) — REST endpoints
- [DEVELOPMENT.md](./DEVELOPMENT.md#common-tasks) — Common operations

## Document Overview

| Document | Purpose | Audience | Length |
|----------|---------|----------|--------|
| [README.md](../README.md) | Project overview | Everyone | 1 page |
| [CLEAN_SETUP.md](../CLEAN_SETUP.md) | Quick start | Developers | 5 min read |
| [AUTHENTICATION.md](./AUTHENTICATION.md) | Auth deep dive | Developers/Architects | 15 min read |
| [DEVELOPMENT.md](./DEVELOPMENT.md) | Dev guide | Developers | 20 min read |
| [MIGRATION.md](./MIGRATION.md) | Upgrade guide | DevOps/Senior devs | 30 min read |
| [RODAUTH_MIGRATION_SUMMARY.md](./RODAUTH_MIGRATION_SUMMARY.md) | Migration overview | Team leads | 10 min read |
| [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) | Deployment process | DevOps | 20 min to execute |

## External Resources

- [Rodauth Documentation](https://rodauth.jeremyevans.net/)
- [JSON Web Token (JWT) RFC 7519](https://tools.ietf.org/html/rfc7519)
- [Rails Guides](https://guides.rubyonrails.org/)
- [GraphQL Ruby](https://graphql-ruby.org/)
- [Next.js Documentation](https://nextjs.org/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## Version History

| Date | Version | Change |
|------|---------|--------|
| 2026-03-21 | 1.0 | Initial documentation for Rodauth migration |

## Questions?

- **Setup questions**: See [CLEAN_SETUP.md](../CLEAN_SETUP.md)
- **Auth questions**: See [AUTHENTICATION.md](./AUTHENTICATION.md)
- **Dev questions**: See [DEVELOPMENT.md](./DEVELOPMENT.md)
- **Upgrade questions**: See [MIGRATION.md](./MIGRATION.md)
- **Deployment questions**: See [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)
- **System design questions**: See [RODAUTH_MIGRATION_SUMMARY.md](./RODAUTH_MIGRATION_SUMMARY.md)

## Contributing to Documentation

When adding new features or making changes:

1. Update relevant `.md` file
2. Keep examples current
3. Update this INDEX if adding new docs
4. Follow existing markdown style
5. Link to related sections

---

**Last Updated**: 2026-03-21
**Maintainer**: Development Team
**Status**: Complete
