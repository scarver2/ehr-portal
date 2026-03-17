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
