# EHR Portal Roadmap

Phase 1 – Infrastructure  
Phase 2 – Rails API  
Phase 3 – Domain modeling  
Phase 4 – GraphQL queries  
Phase 5 – Next.js UI  
Phase 6 – Visualization  
Phase 7 – Deployment

# EHR Portal Roadmap

This project follows an **SDLC-first approach**, ensuring the development
environment, infrastructure, testing, and deployment pipeline are operational
before significant application development begins.

---

# Phase 1 — Repository Foundation

Initialize the monorepo structure and documentation.

Goals:

• Establish consistent project layout  
• Document architecture and development workflow  
• Ensure new developers can understand the project quickly  

Tasks:

- Initialize git repository
- Create project README
- Create architecture documentation
- Create roadmap and TODO documents
- Establish directory structure

Structure:

apps/
docs/
infrastructure/
bin/

Deliverable:

Clean repository foundation.

---

# Phase 2 — Development Environment

Create a reproducible local development environment.

Goals:

• One-command development startup  
• Containerized infrastructure  
• Consistent developer environment  

Tasks:

- Docker compose configuration
- PostgreSQL container
- Redis container
- Development helper scripts (`bin/dev`)
- Environment variable configuration

Deliverable:

Local environment running via:

bin/dev

---

# Phase 3 — Application Scaffolding

Generate application frameworks and connect them to infrastructure.

Goals:

• Functional application skeletons  
• Framework configuration complete  

Tasks:

Rails API:

- Generate Rails API app
- Configure PostgreSQL
- Configure Redis cache
- Install GraphQL
- Install RSpec
- Install ActiveAdmin

Next.js Portal:

- Generate Next.js application
- Configure SCSS
- Install UI dependencies
- Establish layout components

Deliverable:

Rails and Next applications running.

---

# Phase 4 — Testing Infrastructure

Testing should exist before major development begins.

Goals:

• Ensure test environment works  
• Prevent regressions early  

Tasks:

Rails:

- RSpec configuration
- FactoryBot setup
- Simple model tests

Next.js:

- Jest or Vitest setup
- React component test example

Deliverable:

Tests run successfully in CI and locally.

---

# Phase 5 — CI/CD Pipeline

Establish automated build and test pipeline.

Goals:

• Automated verification of commits  
• Prevent broken builds  

Tasks:

- GitHub Actions configuration
- Rails test job
- Next.js build job
- Linting checks
- CI status badges

Deliverable:

CI pipeline running on every push.

---

# Phase 6 — Observability

Introduce lightweight instrumentation for monitoring and debugging.

Goals:

• Visibility into system behavior  
• Trace API requests  

Tasks:

- OpenTelemetry integration
- Rails request instrumentation
- GraphQL query tracing
- Structured logging

Deliverable:

Observable application behavior.

---

# Phase 7 — Deployment Infrastructure

Prepare production deployment environment.

Goals:

• Reliable deploy process  
• Container-based deployment  

Tasks:

- Docker build configuration
- Kamal deployment configuration
- DigitalOcean server provisioning
- Production environment variables
- HTTPS via Let's Encrypt

Deliverable:

Working production deployment.

---

# Phase 8 — Domain Modeling

Begin application development.

Goals:

• Establish core healthcare domain models  

Tasks:

Models:

- Patient
- Provider
- Location
- Encounter
- Observation (Vitals)
- Diagnosis

Deliverable:

Domain schema implemented.

---

# Phase 9 — GraphQL API

Expose domain models through GraphQL.

Tasks:

Queries:

- Patient search
- Patient chart
- Encounter timeline
- Vitals retrieval

Deliverable:

Functional GraphQL API.

---

# Phase 10 — Frontend Application

Build the user interface.

Tasks:

- Dashboard layout
- Sidebar navigation
- Patient search interface
- Patient chart page
- Encounter timeline component

Deliverable:

Operational UI.

---

# Phase 11 — Visualization Enhancements

Add advanced UI features.

Tasks:

- ECG monitor animation
- Vitals radial visualization
- Pulse glow indicator

Deliverable:

Enhanced clinical visualization.

---

# Phase 12 — Final Polishing

Prepare demo and documentation.

Tasks:

- Seed realistic data
- UI polish
- Documentation updates
- Deployment validation

Done.

## License

Copyright &copy;2026 [Stan Carver II](http://stancarver.com) All rights reserved.