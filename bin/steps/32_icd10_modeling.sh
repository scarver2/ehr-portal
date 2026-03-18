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

# TODO: add ICD10 specs

info "Adding Icd10 RBS type signature..."
cat << 'EOF' > sig/app/models/icd10.rbs
# sig/app/models/icd10.rbs
# Column types derived from db/schema.rb (icd10s table).
# AR generates attribute accessors dynamically; attr_accessor syntax avoids
# Ruby::MethodDefinitionMissing under all_error.

class Icd10 < ApplicationRecord
  attr_accessor id: ::Integer
  attr_accessor code: ::String?
  attr_accessor description: ::String?
  attr_accessor created_at: ::Time
  attr_accessor updated_at: ::Time

  def self.ransackable_attributes: (?untyped auth_object) -> ::Array[::String]
end
EOF
