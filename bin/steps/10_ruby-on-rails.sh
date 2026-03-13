#!/usr/bin/env bash
# bin/steps/10_ruby-on-rails.sh

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
  --skip-bootsnap \
  --skip-jbuilder \
  --skip-kamal \
  --skip-solid \
  --skip-system-test \
  --skip-test

cd ehr-api

info "Downloading .gitignore ..."
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/refs/heads/main/Rails.gitignore
# git add .
# git commit -m "Initial API commit"

# # TODO: lock Ruby version
# cat << 'EOF' > .ruby-version
# $(/usr/bin/ruby -e 'puts RUBY_VERSION')
# EOF

info "Adding RSpec..."
bundle add rspec-rails
bin/rails generate rspec:install
cat << 'EOF' > .rspec
# .rspec

--color
--format documentation
--order random
--require spec_helper
EOF

info "Adding FactoryBot..."
bundle add factory_bot_rails
# mkdir spec/factories
# TODO: add FactoryBot to spec_helper.rb

info "Adding RuboCop..."
bundle add rubocop
bundle add rubocop-capybara
bundle add rubocop-factory_bot
bundle add rubocop-rails
bundle add rubocop-performance
bundle add rubocop-rspec

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
  TargetRubyVersion: 3.4
  Exclude:
    - '.bundle/**/*'
    - 'coverage/**/*'
    - 'tmp/**/*'
    - 'vendor/**/*'
EOF

info "Adding SimpleCov..."
bundle add simplecov
cat << 'EOF' > .simplecov
# frozen_string_literal: true

SimpleCov.external_at_exit = true

SimpleCov.start do
  add_filter 'test'
  enable_coverage_for_eval
end
EOF
# TODO: add SimpleCov to spec_helper.rb

info "Creating database..."
bin/rails db:create

info "Adding Devise..."
bundle add devise
bin/rails g devise:install
bin/rails g devise User
bin/rails db:migrate

info "Adding Faker..."
bundle add faker

info "Adding GraphQL..."
bundle add graphql
bundle add graphql-rails --group development
bin/rails generate graphql:install

# TODO: Insert health check endpoint after 2nd line of routes.rb
# get "/up", to: proc { [200, {}, ["ok"]] }


# fail 'intentionally halted for verification'
