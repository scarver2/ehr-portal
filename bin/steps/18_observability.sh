# bin/steps/18_observability.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Adding Honeybadger gem..."

bundle add honeybadger

info "Configuring Honeybadger..."

cat <<EOF > config/initializers/honeybadger.rb
Honeybadger.configure do |config|
  config.api_key = ENV.fetch("HONEYBADGER_API_KEY")
  config.env = Rails.env
  config.host = "ehr-portal.stancarver.com"
  config.project_root = Rails.root.to_s
  config.ignore_only = []
end
EOF

bundle exec honeybadger install "${HONEYBADGER_API_KEY:?HONEYBADGER_API_KEY must be set}"

# info "Adding Honeybadger to Dockerfile..."

# cat <<EOF >> Dockerfile

# # Honeybadger
# COPY --from=builder /app/vendor/bundle /usr/local/bundle
# EOF

# info "Adding Honeybadger to Docker Compose..."

# cat <<EOF >> docker-compose.yml

# # Honeybadger
#   honeybadger:
#     image: honeybadger/honeybadger:latest
#     environment:
#       HONEYBADGER_API_KEY: ${HONEYBADGER_API_KEY}
# EOF

info "Adding Honeybadger RBS shim..."
cat << 'EOF' > sig/shims/honeybadger.rbs
# sig/shims/honeybadger.rbs
# Minimal stubs for Honeybadger error-tracking methods.
# Remove once honeybadger-ruby ships official RBS definitions.

module Honeybadger
  def self.context: (**untyped pairs) -> void
  def self.notify: (untyped exception_or_message, **untyped opts) -> void
end
EOF

# Overwrite with full application_controller sig now that all methods are known:
# current_user from Devise (step 14), set_honeybadger_context from this step.
cat << 'EOF' > sig/app/controllers/application_controller.rbs
# sig/app/controllers/application_controller.rbs

class ApplicationController < ActionController::Base
  # Provided by Devise — returns the currently authenticated User or nil.
  def current_user: () -> ::User?

  private

  def set_honeybadger_context: () -> void
end
EOF
