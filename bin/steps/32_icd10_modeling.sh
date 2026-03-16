# bin/steps/32_icd10_modeling.sh

# Schema:
# code:string
# description:string

# Steps:
# 1. 
# 2. 
# 3. 

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Generating ICD10 model..."
bin/rails generate model Icd10 code:string description:string

info "Generating ICD10 resource..."
bin/rails generate active_admin:resource Icd10

info "Generating ICD10 type..."
bin/rails generate graphql:object Icd10

info "Generating ICD10 query..."
bin/rails generate graphql:query Icd10

info "Generating ICD10 mutation..."
bin/rails generate graphql:mutation Icd10

info "Generating ICD10 connection..."
bin/rails generate graphql:connection Icd10
