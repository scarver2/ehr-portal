# EHR Portal TODO

## Phase 1 — Repository Foundation

- [x] Initialize git repository
- [x] Create project README
- [x] Create architecture documentation
- [x] Create roadmap and TODO documents
- [x] Establish directory structure

## Phase 2 — Development Environment

- [x] Docker compose configuration
- [x] PostgreSQL container
- [ ] Redis container
- [x] Development helper scripts (`bin/dev`, `bin/bootstrap`)
- [x] Overmind as process manager (consistent across root and all apps)
- [x] Environment variable configuration

## Phase 3 — Application Scaffolding

- [x] Generate Rails API app
- [x] Configure PostgreSQL
- [ ] Configure Redis cache
- [x] Install GraphQL
- [x] Install RSpec
- [x] Install ActiveAdmin
- [x] Generate Next.js application
- [x] Configure SCSS
- [x] Install UI dependencies
- [ ] Establish layout components

## Phase 4 — Testing Infrastructure

- [x] RSpec configuration
- [x] FactoryBot setup
- [x] Simple model tests
- [x] Jest or Vitest setup
- [x] React component test example

## Phase 5 — CI/CD Pipeline

- [x] GitHub Actions configuration
- [x] Rails test job
- [x] Next.js build job
- [x] Linting checks
- [x] CI status badges

## Phase 6 — Observability

- [ ] OpenTelemetry integration
- [ ] Rails request instrumentation
- [ ] GraphQL query tracing
- [ ] Structured logging
- [x] Honeybadger APM error logging

## Phase 7 — Deployment Infrastructure

- [x] Docker build configuration
- [x] Kamal deployment configuration
- [x] Vultr server provisioning
- [x] Production environment variables
- [x] HTTPS via Let's Encrypt

## Phase 8 — Domain Modeling

- [ ] Create models
    - [ ] Administrator (AdminUser)
    - [ ] Allergy
    - [ ] AuditLog
    - [ ] Diagnosis
    - [ ] Document
    - [ ] Encounter
    - [ ] Medication
    - [ ] Note
    - [ ] Patient
    - [ ] Permission
    - [ ] Provider
    - [ ] Role
    - [ ] Treatment
    - [ ] User
    - [ ] Vital
- [ ] Seed data
- [ ] Build patient search
- [ ] Build patient chart
- [ ] Add encounter timeline
- [ ] Add vitals visualization
- [x] Deploy with Kamal

## Phase 9 — GraphQL API

- [ ] Patient search
- [ ] Patient chart
- [ ] Encounter timeline
- [ ] Vitals retrieval

## Phase 10 — Frontend Application

- [ ] Dashboard layout
- [ ] Sidebar navigation
- [ ] Patient search interface
- [ ] Patient chart page
- [ ] Encounter timeline component

## Phase 11 — Visualization Enhancements

- [ ] ECG monitor animation
- [ ] Vitals radial visualization
- [ ] Pulse glow indicator

## Developer Experience (DX)

### ehr-api

- [x] RSpec with FactoryBot for test-driven development
- [x] Guard for TDD watch mode (RSpec + RuboCop auto-run on file save)
- [x] RuboCop with extensions (Rails, RSpec, GraphQL, Performance, CapyBara, FactoryBot)
- [x] Brakeman static security analysis (`bin/security`)
- [x] SimpleCov test coverage reporting
- [x] Better Errors + binding_of_caller for rich in-browser error pages
- [x] Rack Mini Profiler for request performance inspection
- [x] IRBTools for an enhanced Rails console
- [x] GraphiQL IDE mounted at `/graphiql` (development only)
- [x] GraphiQL link in ActiveAdmin utility navigation (development only)
- [x] RBS type signatures with Steep type checker (`bin/typecheck`)
- [ ] OpenTelemetry local tracing (Jaeger or OTEL collector)
- [ ] Seed realistic FHIR-style data for local development

### ehr-portal

- [x] Vitest for unit testing (`bin/test`)
- [x] Playwright for E2E testing (`bin/test --e2e`)
- [x] ESLint for linting (`bun lint`)
- [x] Honeybadger error monitoring (browser, edge, and server configs)
- [x] `bin/steps/` guided build scripts for reproducible project setup
- [x] `bin/bootstrap` step runner with range and from-step support (`10-20`, `10+`)
- [ ] Storybook for UI component development
- [ ] Vitest coverage reporting

## Phase 12 — Final Polishing

- [ ] Seed realistic data
- [ ] UI polish
- [ ] Documentation updates
- [ ] Deployment validation

## License

Copyright &copy;2026 [Stan Carver II](http://stancarver.com) All rights reserved.

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
