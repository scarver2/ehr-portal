#!/usr/bin/env bash
# bin/steps/10_ruby-on-rails-clean.sh
# CLEAN APP SETUP - applies current schema directly without migration evolution
# Use this for new developers instead of running all 40+ evolutionary steps

source "$(dirname "$0")/../_lib.sh"

info "Setting up clean Rails API (Rodauth + Rolify)..."

check "ruby"
check "gem"
check "bundle"
check "rails"

cd apps

# Create Rails API
rails new ehr-api \
  --api \
  --database=postgresql \
  --minimal \
  --skip-git \
  --skip-javascript \
  --skip-hotwire \
  --skip-action-mailer \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-active-storage \
  --skip-jbuilder \
  --skip-kamal \
  --skip-solid \
  --skip-system-test \
  --skip-test

cd ehr-api

# Setup database.yml for local development
cat <<EOF > config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV.fetch("DB_HOST", "localhost") %>
  port: <%= ENV.fetch("DB_PORT", 5432) %>
  username: <%= ENV.fetch("DB_USER", "$(whoami)") %>
  password: <%= ENV.fetch("DB_PASSWORD", "") %>
  max_connections: <%= ENV.fetch("RAILS_MAX_THREADS") { 3 } %>

development:
  <<: *default
  database: ehr_api_development

test:
  <<: *default
  database: ehr_api_test

production:
  <<: *default
  database: ehr_api_production
EOF

info "Creating databases..."
bin/rails db:create

info "Loading current schema (no migration evolution)..."
bin/rails db:schema:load

info "Ruby on Rails setup complete ✓"
