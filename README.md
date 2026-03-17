# ⚕️ EHR Portal

[![Ruby](https://img.shields.io/badge/ruby-3.4.8-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![Rails](https://img.shields.io/badge/rails-8.1.2-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![Next.js](https://img.shields.io/badge/next.js-16.1.6-000000?logo=nextdotjs&logoColor=white)](https://nextjs.org)
[![React](https://img.shields.io/badge/react-19.2.3-61DAFB?logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/typescript-5-3178C6?logo=typescript&logoColor=white)](https://typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/postgresql-17-4169E1?logo=postgresql&logoColor=white)](https://postgresql.org)
[![GraphQL](https://img.shields.io/badge/graphql-2.5-E10098?logo=graphql&logoColor=white)](https://graphql-ruby.org)
[![Bun](https://img.shields.io/badge/bun-1.3.10-fbf0df?logo=bun&logoColor=black)](https://bun.sh)

[![API CI](https://github.com/scarver2/ehr-portal/actions/workflows/api.yml/badge.svg)](https://github.com/scarver2/ehr-portal/actions/workflows/api.yml)
[![Portal CI](https://github.com/scarver2/ehr-portal/actions/workflows/portal.yml/badge.svg)](https://github.com/scarver2/ehr-portal/actions/workflows/portal.yml)
[![Lint](https://github.com/scarver2/ehr-portal/actions/workflows/lint.yml/badge.svg)](https://github.com/scarver2/ehr-portal/actions/workflows/lint.yml)
[![Security](https://github.com/scarver2/ehr-portal/actions/workflows/security.yml/badge.svg)](https://github.com/scarver2/ehr-portal/actions/workflows/security.yml)
[![Coverage](https://codecov.io/gh/scarver2/ehr-portal/branch/main/graph/badge.svg)](https://codecov.io/gh/scarver2/ehr-portal)

Modern Electronic Health Record (EHR) portal for clinical staff.

## Tech Stack
- **API (Ruby on Rails)**
    - [ActiveAdmin](https://activeadmin.info/) administrative dashboard
    - [Brakeman](https://brakemanscanner.org/) security scanner
    - [GraphQL](https://graphql.org/) API
    - [Rails 8](https://rubyonrails.org/)
    - [Ruby 3](https://www.ruby-lang.org/en/)
    - [RSpec](https://rspec.info/) test suite
    - [Rubocop](https://rubocop.org/) linter
    - [SimpleCov](https://github.com/simplecov-ruby/simplecov) test coverage analysis
- **Portal (React)**
    - [ESLint](https://eslint.org/) linter
    - [Jest](https://jestjs.io/) test suite
    - [Next.js 16](https://nextjs.org/)
    - [Playwright](https://playwright.dev/) test suite
    - [Prettier](https://prettier.io/) code formatter
    - [React](https://react.dev/) frontend
    - [TypeScript](https://www.typescriptlang.org/)
    - [Vitest](https://vitest.dev/) test suite
- **Database (PostgreSQL)**
    - [pgadmin4](https://www.pgadmin.org/)
    - [PostgreSQL 17](https://www.postgresql.org/)
- **Queue (Redis)**
    - [Redis](https://redis.io/)
- **OS**
    - [Ubuntu 24.04 LTS](https://ubuntu.com/)

### SDLC & DEVOPS
- [Docker](https://www.docker.com/)
- [Git](https://git-scm.com/)
- [GitHub Actions](https://github.com/features/actions)
- [GitHub](https://github.com/)
- [Kamal](https://kamalapp.dev/) deployment
- [Let's Encrypt](https://letsencrypt.org/) for SSL certificates
- [Vultr](https://www.vultr.com/) server provisioning
- Bash scripts for deployment and management
- Environment secrets management

## Roadmap

See [docs/roadmap.md](docs/roadmap.md) for roadmap.
See [docs/todo.md](docs/todo.md) for TODO list.

## Developer Notes

See [docs/notes.md](docs/notes.md) for notes.

## License

Copyright &copy;2026 [Stan Carver II](http://stancarver.com) All rights reserved.

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/main/nginx/www/made-in-texas.png)
