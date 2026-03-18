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

info "Adding Hospital RBS type signature..."
cat << 'EOF' > sig/app/models/hospital.rbs
# sig/app/models/hospital.rbs
# Column types derived from db/schema.rb (hospitals table).
# AR generates attribute accessors dynamically; attr_accessor syntax avoids
# Ruby::MethodDefinitionMissing under all_error.

class Hospital < ApplicationRecord
  attr_accessor id: ::Integer
  attr_accessor code: ::String?
  attr_accessor description: ::String?
  attr_accessor created_at: ::Time
  attr_accessor updated_at: ::Time

  def self.ransackable_attributes: (?untyped auth_object) -> ::Array[::String]
end
EOF
