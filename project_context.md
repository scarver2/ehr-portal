Project: EHR Portal

Architecture:
- Monorepo
- Rails 8 GraphQL API
- Next.js (TypeScript, Bun, SCSS modules)
- PostgreSQL
- Redis
- Docker for local dev
- Kamal deployment to VPS
- OpenTelemetry instrumentation

Structure:
├── apps
│   ├── ehr-api
│   └── ehr-portal
├── bin
│   ├── _lib.sh
│   ├── bootstrap
│   ├── cleanse
│   └── steps
│       ├── 00_started.sh
│       ├── 02_docker.sh
│       ├── 10_ruby-on-rails.sh
│       ├── 13_active-admin.sh
│       ├── 20_nextjs.sh
│       ├── 30_seed-data.sh
│       ├── 40_test.sh
│       ├── 50_ci.sh
│       ├── 60_observability.sh
│       ├── 70_deploy.sh
│       └── 99_finished.sh
├── docs
│   ├── architecture.md
│   ├── notes.md
│   ├── roadmap.md
│   └── todo.md
├── project_context.md
└── README.md


Design:
- Apple-style UI
- Star Trek Enterprise-D sickbay inspiration
- Vitals visualization (ECG + rings)
- Encounter timeline
- GraphQL API for patient chart

Goal:
Build SDLC infrastructure first (steps 00–99) before application development.
