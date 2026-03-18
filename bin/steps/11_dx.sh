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
require_command "overmind"

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

info "Creating bin/_lib.sh..."
cat << 'EOF' > bin/_lib.sh
#!/usr/bin/env bash
# apps/ehr-api/bin/_lib.sh

_APP_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$_APP_BIN_DIR/.." && pwd)"
unset _APP_BIN_DIR

source "$APP_DIR/../../bin/_lib.sh"

# Root's _lib.sh sets COMMAND_NAME from BASH_SOURCE[1], which resolves to this
# file when scripts source us. Re-resolve to the actual calling script.
COMMAND_NAME="$(basename "${BASH_SOURCE[1]:-$0}")"

cd "$APP_DIR"
EOF
chmod +x bin/_lib.sh

cat << 'EOF' > bin/lint
#!/usr/bin/env bash
# apps/ehr-api/bin/lint
#
# Usage:
#   bin/lint                        # default report (no corrections)
#   bin/lint --autocorrect          # apply corrections

source "$(dirname "$0")/_lib.sh"

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
css: bin/rails dartsass:watch
guard: bin/guard
EOF

info "Overwriting bin/dev..."
cat << 'EOF' > bin/dev
#!/usr/bin/env bash
# apps/ehr-api/bin/dev
# Starts the Rails API development server via Overmind.
# Run from the repo root with bin/dev for the full stack.

source "$(dirname "$0")/_lib.sh"

require_command overmind

exec overmind start -f Procfile.dev "$@"
EOF
chmod +x bin/dev

info "Adding Brakeman..."
bundle add brakeman --group development
cat << 'EOF' > bin/security
#!/usr/bin/env bash
# apps/ehr-api/bin/security
#
# Usage:
#   bin/security                        # default text report
#   bin/security -f json                # JSON output
#   bin/security -f html -o report.html # HTML report to file
#   bin/security --quiet                # warnings only, no progress

source "$(dirname "$0")/_lib.sh"

exec bundle exec brakeman "$@"
EOF
chmod +x bin/security

info "Adding Guard..."
bundle add guard --group "development, test"

cat << 'EOF' > Guardfile
# Guardfile
# Run with: bin/guard

clearing :on

# ── Bundler ────────────────────────────────────────────────────────────────
# Runs `bundle install` automatically when Gemfile changes.
# bundler_output_as_trigger: false prevents Gemfile.lock updates from re-firing.
guard :bundler, bundler_output_as_trigger: false do
  watch("Gemfile")
end

# ── RuboCop ────────────────────────────────────────────────────────────────
# --no-color suppresses ANSI cursor-position probes that leak as escape
# sequences (^[[32;2R) when Guard runs inside Overmind/Foreman pipes.
guard :rubocop, all_on_start: false, cli: %w[--format fuubar --display-cop-names --no-color] do
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
# apps/ehr-api/bin/guard

source "$(dirname "$0")/_lib.sh"

exec bundle exec guard "$@"
EOF
chmod +x bin/guard

# TODO: add health check request specs
# TODO: Insert health check endpoint after 2nd line of routes.rb
# get "/up", to: proc { [200, {}, ["ok"]] }

# TODO: add base application specs

info "Setting up RBS type signatures and Steep type checker..."
bundle add rbs --group "development, test"
bundle add steep --require false --group development

cat << 'EOF' > rbs_collection.yaml
# apps/ehr-api/rbs_collection.yaml
# Declares sources for third-party RBS type definitions.
# Run `bundle exec rbs collection install` to fetch into .rbs_collection/.
# Commit rbs_collection.yaml.lock; gitignore .rbs_collection/.

sources:
  - type: git
    name: ruby/gem_rbs_collection
    remote: https://github.com/ruby/gem_rbs_collection.git
    revision: main
    path: gems

path: .rbs_collection

gems:
  # Rails / Rack — RBS bundled in gems and/or in gem_rbs_collection
  - name: actionpack
  - name: activesupport
  - name: railties
  - name: rack

  # No RBS available; shimmed in sig/shims/ instead
  - name: activeadmin
    ignore: true
  - name: bootsnap
    ignore: true
  - name: devise
    ignore: true
  - name: factory_bot_rails
    ignore: true
  - name: graphql
    ignore: true
  - name: honeybadger
    ignore: true
  - name: propshaft
    ignore: true
  - name: rspec-rails
    ignore: true
  - name: simplecov
    ignore: true
  - name: solid_queue
    ignore: true
EOF

bundle exec rbs collection install

mkdir -p sig/app/models sig/app/controllers \
         sig/app/graphql/types sig/app/graphql/mutations sig/app/graphql/resolvers \
         sig/shims

cat << 'EOF' > sig/app/models/application_record.rbs
# sig/app/models/application_record.rbs

class ApplicationRecord < ActiveRecord::Base
  include GlobalID::Identification
end
EOF

# Minimal initial sig — current_user added in step 14, set_honeybadger_context in step 18.
cat << 'EOF' > sig/app/controllers/application_controller.rbs
# sig/app/controllers/application_controller.rbs

class ApplicationController < ActionController::Base
end
EOF

cat << 'STEEP' > Steepfile
# apps/ehr-api/Steepfile
# https://github.com/soutaro/steep

D = Steep::Diagnostic

# All application targets share the same sig/ tree (including sig/shims/).
#
# :models     → all_error: models are the domain core; strict checking pays off here.
# :controllers → lenient: blocked by graphql-ruby and devise shim gaps.
# :graphql    → lenient: blocked by graphql-ruby having no official RBS.

target :models do
  signature "sig"

  check "app/models"

  # all_error with MethodDefinitionMissing downgraded to :information.
  # AR generates column accessors at runtime — they can't be found in source.
  # All other diagnostics (NoMethod, TypeError, nil-safety, etc.) remain errors.
  configure_code_diagnostics(D::Ruby.all_error) do |c|
    c[D::Ruby::MethodDefinitionMissing] = :information
  end
end

target :controllers do
  signature "sig"

  check "app/controllers"

  configure_code_diagnostics(D::Ruby.lenient)
end

target :graphql do
  signature "sig"

  check "app/graphql"

  configure_code_diagnostics(D::Ruby.lenient)
end
STEEP

cat << 'EOF' > bin/typecheck
#!/usr/bin/env bash
# apps/ehr-api/bin/typecheck
# Install the RBS collection then run Steep type checking.
#
# Examples:
#   bin/typecheck                  # check all targets
#   bin/typecheck --log-level=info # verbose output

source "$(dirname "$0")/_lib.sh"

bundle exec rbs collection install
exec bundle exec steep check "$@"
EOF
chmod +x bin/typecheck

cat << 'EOF' > bin/test
#!/usr/bin/env bash
# apps/ehr-api/bin/test
# Run the RSpec test suite. Any extra arguments are forwarded to rspec.
#
# Examples:
#   bin/test                                        # run all specs
#   bin/test spec/models/provider_spec.rb           # run a single file
#   bin/test spec/models/provider_spec.rb:12        # run one example by line
#   bin/test --format documentation                 # verbose output

source "$(dirname "$0")/_lib.sh"

exec bundle exec rspec "$@"
EOF
chmod +x bin/test

cat << 'EOF' > bin/outdated
#!/usr/bin/env bash
# apps/ehr-api/bin/outdated
#
# Usage:
#   bin/outdated

source "$(dirname "$0")/_lib.sh"

outdated_command ruby

exec bundle outdated "$@"
EOF
chmod +x bin/outdated

cat << 'EOF' > bin/update
#!/usr/bin/env bash
# apps/ehr-api/bin/update
#
# Usage:
#   bin/update           # interactive menu
#   bin/update ruby      # upgrade Ruby via Homebrew
#   bin/update gems      # bundle update
#   bin/update all       # ruby + gems

source "$(dirname "$0")/_lib.sh"

update_ruby() {
  info "Upgrading Ruby..."
  brew upgrade ruby
  success "Ruby upgraded"
}

update_gems() {
  info "Updating gems..."
  bundle update
  success "Gems updated"
}

run_update() {
  case "$1" in
    ruby) update_ruby ;;
    gems) update_gems ;;
    all)
      update_ruby
      update_gems
      ;;
    *) abort "Unknown target: $1" ;;
  esac
}

if [[ $# -gt 0 ]]; then
  run_update "$1"
else
  selection=$(select_menu "Select what to update:" "ruby" "gems" "all")
  run_update "$selection"
fi
EOF
chmod +x bin/update
