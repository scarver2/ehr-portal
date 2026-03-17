# bin/steps/36_patients_modeling.sh

# Schema:
# code:string
# description:string

# Steps:
# 1. 
# 2. 
# 3. 

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Generating Patient model..."
bin/rails generate model Patient code:string description:string

info "Generating Patient resource..."
bin/rails generate active_admin:resource Patient

info "Generating Patient type..."
bin/rails generate graphql:object Patient

info "Generating Patient query..."
bin/rails generate graphql:query Patient

info "Generating Patient mutation..."
bin/rails generate graphql:mutation Patient

info "Generating Patient connection..."
bin/rails generate graphql:connection Patient

# TODO: add Patient specs
