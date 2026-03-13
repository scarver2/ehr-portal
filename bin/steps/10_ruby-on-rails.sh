#!/usr/bin/env bash
# bin/steps/10_ruby-on-rails.sh

source "$(dirname "$0")/../_lib.sh"

info "Checking prerequisites for Ruby on Rails..."

check "ruby"
check "gem"
check "bundle"
check "rails"

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

info "Creating database..."
bin/rails db:create
