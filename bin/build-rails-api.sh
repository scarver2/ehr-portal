#!/usr/bin/env bash
# bin/build-rails-api.sh

source "$(dirname "$0")/_lib.sh"

banner

info "Checking prerequisites..."

check "ruby"
check "gem"
check "bundle"
check "rails"
check "curl"
check "git"

info "Creating Rails API..."

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

# TODO: add Git
# curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/refs/heads/main/Rails.gitignore
# git add .
# git commit -m "Initial API commit"

# lock Ruby version
cat << 'EOF' > .ruby-version
$(/usr/bin/ruby -e 'puts RUBY_VERSION')
EOF

# create database
bin/rails db:create

fail 'intentionally halted for verification'

# add RSpec
bundle add rspec-rails
bin/rails generate rspec:install
# TODO: add .rspec
cat << 'EOF' > .rspec
# .rspec
EOF

# add FactoryBot
bundle add factory_bot_rails

# add RuboCop
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
  TargetRubyVersion: 4.0
  Exclude:
    - '.bundle/**/*'
    - 'coverage/**/*'
    - 'tmp/**/*'
    - 'vendor/**/*'
EOF

# add SimpleCov
bundle add simplecov
cat << 'EOF' > .simplecov
# frozen_string_literal: true

SimpleCov.external_at_exit = true

SimpleCov.start do
  add_filter 'test'
  enable_coverage_for_eval
end
EOF

# add Devise
bundle add devise
bin/rails g devise:install
bin/rails g devise User
bin/rails db:migrate

# add ActiveAdmin
bundle add activeadmin
rails generate active_admin:install
bin/rails g active_admin:install
bin/rails generate devise AdminUser
bin/rails db:migrate
# TODO config ActiveAdmin to use Devise for authentication


# add Faker
bundle add faker

# TODO: add seeds

# add GraphQL
bundle add graphql
rails generate graphql:install

