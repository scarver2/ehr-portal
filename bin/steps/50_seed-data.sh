#!/usr/bin/env bash
# bin/steps/50_seed-data.sh

source "$(dirname "$0")/../_lib.sh"

info "Seeding database..."
cd ../ehr-api
bin/rails db:seed
