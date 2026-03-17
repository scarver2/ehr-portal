# bin/steps/33_medications_modeling.sh

# Schema:
# code:string
# description:string

# Steps:
# 1. 
# 2. 
# 3. 

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Generating Medication model..."
bin/rails generate model Medication code:string description:string

info "Generating Medication resource..."
bin/rails generate active_admin:resource Medication

info "Generating Medication type..."
bin/rails generate graphql:object Medication

info "Generating Medication query..."
bin/rails generate graphql:query Medication

info "Generating Medication mutation..."
bin/rails generate graphql:mutation Medication

info "Generating Medication connection..."
bin/rails generate graphql:connection Medication

# TODO: add Medication specs
