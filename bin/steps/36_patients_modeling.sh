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

info "Adding Patient RBS type signature..."
cat << 'EOF' > sig/app/models/patient.rbs
# sig/app/models/patient.rbs
# Column types derived from db/schema.rb (patients table).
# AR generates attribute accessors dynamically; attr_accessor syntax avoids
# Ruby::MethodDefinitionMissing under all_error.

class Patient < ApplicationRecord
  attr_accessor id: ::Integer
  attr_accessor code: ::String?
  attr_accessor description: ::String?
  attr_accessor created_at: ::Time
  attr_accessor updated_at: ::Time

  def self.ransackable_attributes: (?untyped auth_object) -> ::Array[::String]
end
EOF
