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
  # drain_timeout: 30
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

ssh:
  user: deploy

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
