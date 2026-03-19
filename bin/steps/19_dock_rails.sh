# bin/steps/19_dock_rails.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Creating Dockerfile for Rails API..."

cat << 'EOF' > Dockerfile
# apps/ehr-api/Dockerfile
FROM ruby:4.0.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

# Web server (default)
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

# Sidekiq worker — Kamal worker role overrides CMD:
#   servers.worker.cmd: bundle exec sidekiq -C config/sidekiq.yml
EOF

info "Kamal worker role (config/deploy.api.yml servers.worker) runs:"
info "  bundle exec sidekiq -C config/sidekiq.yml"