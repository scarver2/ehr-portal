#!/usr/bin/env bash
# bin/steps/11_dx.sh

# TODO: bundle add gems to proper groups
# TODO: bundle add gems with require: false when appropriate

source "$(dirname "$0")/../_lib.sh"

info "Checking prerequisites for Rails..."

check "ruby"
check "gem"
check "bundle"
check "rails"
check "curl"
check "git"

info "Creating Rails API..."

cd apps/ehr-api

info "Downloading .gitignore ..."
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/refs/heads/main/Rails.gitignore

info "Locking Ruby version..."
cat << 'EOF' > .ruby-version
$RUBY_VERSION
EOF

info "Adding RSpec..."
bundle add rspec-rails --group "development, test"
bundle add rspec-its --group "development, test"

bin/rails generate rspec:install
cat << 'EOF' > .rspec
# .rspec

--color
--format documentation
--order random
--require spec_helper
EOF

info "Adding FactoryBot..."
bundle add factory_bot_rails --group "development, test"
# mkdir spec/factories
# TODO: add FactoryBot to spec_helper.rb

info "Adding RuboCop..."
bundle add rubocop --group development
bundle add rubocop-capybara --group development
bundle add rubocop-factory_bot --group development
bundle add rubocop-rails --group development
bundle add rubocop-performance --group development
bundle add rubocop-rspec --group development

cat << 'EOF' > .rubocop.yml
# .rubocop.yml

inherit_from:
  - .rubocop_todo.yml

plugins:
  - rubocop-capybara
  - rubocop-factory_bot
  - rubocop-performance
  - rubocop-rails
  - rubocop-rspec

AllCops:
  NewCops: enable
  TargetRubyVersion: $RUBY_VERSION
  Exclude:
    - '.bundle/**/*'
    - 'coverage/**/*'
    - 'tmp/**/*'
    - 'vendor/**/*'
EOF

cat << 'EOF' > .rubocop_todo.yml
# apps/ehr-api/.rubocop_todo.yml
EOF

cat << 'EOF' > bin/lint
#!/usr/bin/env bash
set -euo pipefail
exec bundle exec rubocop "$@"
EOF
chmod +x bin/lint

info "Adding SimpleCov..."
bundle add simplecov --group "development, test"
cat << 'EOF' > .simplecov
# frozen_string_literal: true

SimpleCov.external_at_exit = true

SimpleCov.start do
  add_filter 'test'
  enable_coverage_for_eval
end
EOF
# TODO: add SimpleCov to spec_helper.rb

info "Adding Procfile.dev..."
cat << 'EOF' > Procfile.dev
# apps/ehr-api/Procfile.dev
web: bin/rails server -p 3000
EOF

info "Overwriting bin/dev..."
cat << 'EOF' > bin/dev
#!/usr/bin/env bash
# apps/ehr-api/bin/dev

if ! gem list foreman -i --silent; then
  echo "Installing foreman..."
  gem install foreman
fi

exec foreman start -f Procfile.dev "$@"
EOF

info "Adding Brakeman..."
bundle add brakeman --group development
cat << 'EOF' > bin/security
#!/usr/bin/env bash
set -euo pipefail
exec bundle exec brakeman "$@"
EOF
chmod +x bin/security

info "Adding Guard..."
bundle add guard --group "development, test"

cat << 'EOF' > Guardfile
# Guardfile
# Run with: bin/guard

clearing :on

# ── RuboCop ────────────────────────────────────────────────────────────────
guard :rubocop, all_on_start: false, cli: %w[--format fuubar --display-cop-names] do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

# ── RSpec ──────────────────────────────────────────────────────────────────
guard :rspec, cmd: "bundle exec rspec --format documentation", all_on_start: false do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  rspec = dsl.rspec

  # Re-run all specs when helpers change
  watch(rspec.spec_helper)  { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch("spec/rails_helper.rb") { rspec.spec_dir }

  # Spec files run themselves
  watch(rspec.spec_files)

  # Models → spec/models/
  watch(%r{^app/models/(.+)\.rb$}) { |m| "spec/models/#{m[1]}_spec.rb" }

  # GraphQL types/mutations/resolvers → spec/graphql/**/*_spec.rb
  watch(%r{^app/graphql/(.+)\.rb$}) { |m| "spec/graphql/#{m[1]}_spec.rb" }

  # ActiveAdmin resources → spec/requests/admin/*_spec.rb
  watch(%r{^app/admin/(.+)\.rb$}) { |m| "spec/requests/admin/#{m[1]}_spec.rb" }

  # GraphQL controller → spec/requests/graphql_spec.rb
  watch("app/controllers/graphql_controller.rb") { "spec/requests/graphql_spec.rb" }

  # Factories → run the corresponding model spec
  watch(%r{^spec/factories/(.+)\.rb$}) { |m| "spec/models/#{m[1].singularize}_spec.rb" }
end
EOF

cat << 'EOF' > bin/guard
#!/usr/bin/env bash
set -euo pipefail

# Point at the containerized Postgres used in development
export DB_HOST=localhost
export DB_PORT=5433
export DB_USER=postgres
export DB_PASSWORD=postgres

exec bundle exec guard "$@"
EOF
chmod +x bin/guard

# TODO: add health check request specs
# TODO: Insert health check endpoint after 2nd line of routes.rb
# get "/up", to: proc { [200, {}, ["ok"]] }

# TODO: add base application specs
