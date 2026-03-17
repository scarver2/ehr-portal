#!/usr/bin/env bash
# bin/steps/15_graphql.sh

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

check "bundle"

info "Adding GraphQL..."
bundle add graphql
bundle add graphql-rails --group development
bin/rails generate graphql:install

# TODO: add GraphQL unit and request specs
