#!/usr/bin/env bash
# bin/steps/11_security.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Adding CORS..."
bundle add rack-cors

echo "config/initializers/cors.rb"
cat << 'EOF' > config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://ehr.stancarver.com"

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end
end
EOF

info "Adding rate limiting..."
bundle add rack-attack

info "Adding authorization gems..."
bundle add pundit

info "Adding Pundit RBS shim..."
cat << 'EOF' > sig/shims/pundit.rbs
# sig/shims/pundit.rbs
# Minimal stubs for Pundit authorization helpers.
# Remove once pundit ships official RBS definitions.

module Pundit
  module Authorization
    def authorize: (untyped record, ?::Symbol? query) -> untyped
    def policy: (untyped record) -> untyped
    def policy_scope: (untyped scope) -> untyped
  end
end
EOF

info "Adding Devise..."
bundle add devise
bin/rails g devise:install
bin/rails g devise User
# bin/rails db:migrate

# TODO: add Devise specs
