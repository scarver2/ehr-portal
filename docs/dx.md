# EHR Portal Developer Experience (DX)

## Features

### **CLI Scripts & Automation**
- **One-command setup** — `bin/bootstrap` with guided steps, dependency checking, and resumable state
- **Local dev stack** — `bin/dev` starts full stack (Postgres + pgAdmin + Rails + Sidekiq + Next.js) via Overmind
- **Docker lifecycle** — `bin/up`, `bin/down`, `bin/restart` for container management
- **Health aggregation** — `bin/health` runs test/lint/coverage across all apps with summarized reporting
- **Smoke tests** — `bin/smoke` validates API health, GraphQL introspection, auth, AdminPanel login
- **Deployment helpers** — `bin/deploy` with preflight checks (Git dirty check, Docker running verification)

### **App-Level Development**
- **Fast test feedback** — `bin/test` / `bin/spec` with file-specific and line-number-based execution
- **Linting with autocorrect** — `bin/lint` with `--fix` support for both Rails and Next.js
- **Type checking** — `bin/typecheck` (Steep/RBS for Rails, TypeScript for Next.js)
- **Code coverage reports** — `bin/coverage` with auto-opening HTML reports
- **Security scanning** — `bin/security` (Brakeman for Rails)
- **Full CI locally** — `bin/ci` runs the entire CI suite before pushing

### **Code Quality**
- **RuboCop with plugins** — Rails, RSpec, GraphQL, FactoryBot, Capybara, Performance rules
- **Type safety** — RBS annotations + Steep static checker, full TypeScript in Next.js
- **Comprehensive testing** — RSpec, Vitest, Playwright E2E with browser UI mode
- **Coverage tracking** — SimpleCov with Coveralls integration

### **Testing & Fixtures**
- **Rich seed data** — Domain-organized seeds (patients, providers, specialties, ICD-10 codes, meds)
- **Faker-based generation** — Realistic test data
- **FactoryBot factories** — DRY test object creation
- **E2E testing** — Playwright with visual debugging support

### **Docker & Local Development**
- **Docker Compose stack** — PostgreSQL 18, Redis 7, pgAdmin 4 pre-configured
- **Health checks built in** — Services monitored automatically
- **Query profiling** — pg_stat_statements enabled on Postgres
- **Hot reload** — Overmind manages dev processes with file watching

### **Deployment & CI/CD**
- **Kamal deployment configs** — Service-aware deployment with separate web/worker roles
- **Post-deploy hooks** — Automatic db:migrate + db:seed + Honeybadger notification
- **Selective CI triggers** — Workflows run only for affected apps (ehr-api/ vs ehr-portal/)
- **Multi-job linting** — Parallel RuboCop, Steep, ESLint validation

### **Organization & Discoverability**
- **Monorepo clarity** — apps/ separation with shared root utilities
- **Numbered bootstrap steps** — 00-99 sequencing with clear groups (Prerequisites, API setup, Portal, Models, Seeding, UI)
- **Modular shell functions** — Reusable checks, messaging, step execution, prompts
- **State persistence** — Bootstrap tracks completed steps, resumable on failure

### **Documentation**
- **Script headers** — All bin scripts have usage examples and descriptions
- **Architecture diagrams** — Request flows for API, Auth, Real-Time Eligibility
- **Roadmap & TODO tracking** — Visibility into planned work
- **Database notes** — PostgreSQL-specific guidance
- **Step reference docs** — Complete breakdown of bootstrap sequence

### **Developer Ergonomics**
- **Interactive prompts** — Confirmation for destructive ops (cleanse, deploy)
- **Helpful error messages** — Consistent messaging (success, info, fail, abort)
- **Package manager choice** — Bun for Next.js (faster than npm), Bundler for Rails
- **Frozen lockfiles** — Reproducible builds in CI
- **Alias convenience** — `bin/spec` as muscle-memory alias for `bin/test`

### **Real-Time & Advanced Features**
- **WebSocket support** — ActionCable for live insurance eligibility verification
- **Background jobs** — Sidekiq with Redis persistence
- **State machines** — AASM for complex workflows (insurance verification)
- **Error tracking** — Honeybadger with deployment correlation
- **GraphQL** — Full introspection, type-safe query generation for frontend

## License

Copyright &copy;2026 [Stan Carver II](http://stancarver.com) All rights reserved.

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
