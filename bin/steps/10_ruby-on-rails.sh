#!/usr/bin/env bash
# bin/steps/10_ruby-on-rails.sh

source "$(dirname "$0")/../_lib.sh"

info "Checking prerequisites for Ruby on Rails..."

check "ruby"
check "gem"
check "bundle"
check "rails"

info "Creating Rails API..."

cd apps

# obsessive, I know.
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

cat <<EOF > config/database.yml 
# apps/ehr-api/config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV["DB_HOST"] %>
  port: <%= ENV.fetch("DB_PORT", 5432) %>
  username: <%= ENV["DB_USER"] %>
  password: <%= ENV["DB_PASSWORD"] %>
  max_connections: <%= ENV.fetch("RAILS_MAX_THREADS") { 3 } %>
  # pool: <%= ENV.fetch("RAILS_MAX_THREADS", 5) %>

development:
  <<: *default
  host: localhost
  database: ehr_api_development

test:
  <<: *default
  host: localhost
  database: ehr_api_test

production:
  <<: *default
  database: ehr_api_production
EOF

info "Creating database..."
bin/rails db:create
