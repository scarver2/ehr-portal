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


# TODO: Insert health check endpoint after 2nd line of routes.rb
# get "/up", to: proc { [200, {}, ["ok"]] }


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

# fail 'intentionally halted for verification'
