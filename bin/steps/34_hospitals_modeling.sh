# bin/steps/34_hospitals_modeling.sh

# Schema:
# code:string
# description:string

# Steps:
# 1. 
# 2. 
# 3. 

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Generating Hospital model..."
bin/rails generate model Hospital code:string description:string

info "Generating Hospital resource..."
bin/rails generate active_admin:resource Hospital

info "Generating Hospital type..."
bin/rails generate graphql:object Hospital

info "Generating Hospital query..."
bin/rails generate graphql:query Hospital

info "Generating Hospital mutation..."
bin/rails generate graphql:mutation Hospital

info "Generating Hospital connection..."
bin/rails generate graphql:connection Hospital

# TODO: add Hospital specs
