#!/usr/bin/env bash
# bin/steps/03_kamal.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

info "Checking prerequisites for Kamal..."

check "kamal"

mkdir -p config

cat << 'EOF' > config/deploy.api.yml
# config/deploy.api.yml
service: ehr-api

image: ghcr.io/scarver2/ehr-api

builder:
  arch: amd64
  cache:
    type: registry
    options: mode=max

proxy:
  ssl: true
  host: api.ehr.stancarver.com
  app_port: 3000
  healthcheck:
    path: /up

registry:
  server: ghcr.io
  username: scarver2
  password:
    - GITHUB_TOKEN

servers:
  web:
    - 45.76.237.124
  worker:
    hosts:
      - 45.76.237.124
    cmd: bundle exec sidekiq -C config/sidekiq.yml

ssh:
  user: deploy

env:
  secret:
    - SECRET_KEY_BASE
    - DB_USER
    - DB_PASSWORD
    - HONEYBADGER_API_KEY
    - REDIS_URL

accessories:
  postgres:
    image: postgres:18
    host: 45.76.237.124
    port: 5432
    env:
      clear:
        POSTGRES_DB: ehr_api_production
      secret:
        - POSTGRES_USER
        - POSTGRES_PASSWORD
    volumes:
      - ehr_api_postgres_data:/var/lib/postgresql

  redis:
    image: redis:7
    host: 45.76.237.124
    port: 6379
    volumes:
      - ehr_api_redis_data:/data

EOF

cat << 'EOF' > config/deploy.portal.yml
# config/deploy.portal.yml
service: ehr-portal

image: ghcr.io/scarver2/ehr-portal

builder:
  arch: amd64
  cache:
    type: registry
    options: mode=max

proxy:
  ssl: true
  host: ehr.stancarver.com
  app_port: 3000
  healthcheck:
    path: /api/up

registry:
  server: ghcr.io
  username: scarver2
  password:
    - GITHUB_TOKEN

servers:
  web:
    - 45.76.237.124

ssh:
  user: deploy

EOF
