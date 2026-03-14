# bin/steps/19_dock_rails.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Creating Dockerfile for Rails API..."

cat << 'EOF' > Dockerfile
# apps/ehr-api/Dockerfile
FROM ruby:3.4.8

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

# CMD ["bin/rails", "server", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
EOF