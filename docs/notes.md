# EHR Portal Developer Notes

_My ruminations while turning this idea into a working application._

## bin scripts

### Top-level (monorepo root)

Scripts in `bin/` and `bin/steps/` drive the guided build of the entire project.

```bash
bin/dev                          # Start full stack (Docker + all processes via Overmind)
bin/bootstrap                    # Guided project build (prompts for confirmation)
bin/bootstrap run                # Run all steps without prompt
bin/bootstrap list               # List available steps
bin/bootstrap graph              # Show step dependency graph
bin/bootstrap doctor             # Check environment prerequisites
bin/bootstrap reset              # Clear pipeline state
bin/bootstrap 20                 # Run a specific step
bin/bootstrap 10-20              # Run steps 10 through 20 (inclusive)
bin/bootstrap 10+                # Run steps from 10 to end
```

### bin/steps — Step Groups

Steps are numbered to communicate intent and sequencing at a glance.
Each group builds on the previous; run them in order.

| Range   | Group                    | Description                                          |
|---------|--------------------------|------------------------------------------------------|
| 00–09   | Prerequisites            | Environment checks, Docker Compose, Kamal config     |
| 10–19   | Rails API                | Rails app, DX tools, ActiveAdmin, GraphQL, Docker    |
| 20–29   | Next.js Portal           | Next.js app, GraphQL client, Docker                  |
| 30–39   | Domain Modeling          | AR models, ActiveAdmin resources, GraphQL types      |
| 40–49   | Seed Data                | Realistic seed data for each domain model            |
| 50–59   | UI Pages                 | Next.js pages and components wired to GraphQL        |
| 90–99   | Finalization             | Final checklist, deployment validation               |

```bash
bin/steps/00_started.sh               # Prerequisites check
bin/steps/01_env.sh                   # Environment variables
bin/steps/02_docker.sh                # Docker Compose setup
bin/steps/03_kamal.sh                 # Kamal deployment config
bin/steps/10_ruby-on-rails.sh         # Rails app generation, database schema
bin/steps/11_dx.sh                    # DX gems: RSpec, RuboCop, Guard, Brakeman,
                                      #   SimpleCov, RBS/Steep type checking
bin/steps/12_solid_queue.sh           # Solid Queue background jobs
bin/steps/13_security.sh             # Security configuration
bin/steps/14_activeadmin.sh           # ActiveAdmin + Devise setup, Devise RBS shim
bin/steps/15_graphql.sh               # GraphQL installation, sigs, GraphQL RBS shim
bin/steps/16_seeds.sh                 # Base seed data (admin user)
bin/steps/18_observability.sh         # Honeybadger APM, Honeybadger RBS shim
bin/steps/19_dock_rails.sh            # Dockerize the Rails API
bin/steps/20_nextjs.sh                # Next.js app generation
bin/steps/25_graphql.sh               # GraphQL types and queries (Next.js)
bin/steps/29_dock_nextjs.sh           # Dockerize the Next.js portal
bin/steps/30_administrators_modeling.sh  # AdminUser model + sig
bin/steps/31_providers_modeling.sh       # Provider model + sig + GraphQL type
bin/steps/32_icd10_modeling.sh           # Icd10 model + sig + GraphQL type
bin/steps/33_medications_modeling.sh     # Medication model + sig + GraphQL type
bin/steps/34_hospitals_modeling.sh       # Hospital model + sig + GraphQL type
bin/steps/36_patients_modeling.sh        # Patient model + sig + GraphQL type
bin/steps/40_administrators_seeds.sh     # Admin user seed data
bin/steps/41_providers_seeds.sh          # Provider seed data
bin/steps/42_icd10_seeds.sh              # ICD-10 code seed data
bin/steps/43_medications_seeds.sh        # Medication seed data
bin/steps/44_hospitals_seeds.sh          # Hospital seed data
bin/steps/46_patients_seeds.sh           # Patient seed data
bin/steps/51_providers_ui.sh             # Next.js Provider pages + GraphQL client
bin/steps/56_patients_ui.sh              # Next.js Patient pages (list + chart)
bin/steps/99_finished.sh                 # Final checklist
```

### ehr-api (`apps/ehr-api/bin/`)

```bash
bin/dev        # Start the Rails API development server via Overmind
bin/guard      # Run Guard for TDD (RSpec + RuboCop watch mode)
bin/lint       # Run RuboCop
bin/security   # Run Brakeman static analysis
bin/test       # Run RSpec
bin/typecheck  # Run Steep type checker (installs RBS collection first)
bin/ci         # Run full CI suite locally
bin/jobs       # Start Solid Queue worker
bin/outdated   # Check for outdated gems
bin/setup      # Bootstrap the app (bundle, db:create, db:migrate, db:seed)
```

### ehr-portal (`apps/ehr-portal/bin/`)

```bash
bin/dev        # Start the Next.js dev server on port 3001 (points at API on port 3000)
bin/test       # Run Vitest unit tests (pass --e2e for Playwright, --watch for watch mode)
```

## VPS

Many VPS providers to choose from. I chose Vultr because of it's proximity to my location and previous positive experiences.

## License

Copyright &copy;2026 [Stan Carver II](http://stancarver.com) All rights reserved.

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
