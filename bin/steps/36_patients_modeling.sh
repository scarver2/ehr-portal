# bin/steps/36_patients_modeling.sh

# Schema:
# first_name:string
# last_name:string
# date_of_birth:date
# gender:string
# mrn:string
# phone:string
# email:string
# address:string
# city:string
# state:string
# zip:string

# Steps:
# 1. Generate Patient model in Rails
# 2. Generate Patient resource in ActiveAdmin
# 3. Add ransackable_attributes to Patient model
# 4. Generate Patient type in GraphQL

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Generating Patient model..."
bin/rails generate model Patient \
  first_name:string \
  last_name:string \
  date_of_birth:date \
  gender:string \
  mrn:string \
  phone:string \
  email:string \
  address:string \
  city:string \
  state:string \
  zip:string

info "Generating Patient resource in ActiveAdmin..."
# bin/rails generate active_admin:resource Patient
# To avoid a premature database migration, we'll create the resource manually

cat << 'EOF' > apps/ehr-api/app/admin/patients.rb
# apps/ehr-api/app/admin/patients.rb

ActiveAdmin.register Patient do
  permit_params :first_name, :last_name, :date_of_birth, :gender, :mrn,
                :phone, :email, :address, :city, :state, :zip
end
EOF

info "Adding ransackable_attributes to Patient model..."
cat << 'EOF' > apps/ehr-api/app/models/patient.rb
# apps/ehr-api/app/models/patient.rb
# frozen_string_literal: true

class Patient < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    [
      "address", "city", "created_at", "date_of_birth", "email",
      "first_name", "gender", "id", "id_value", "last_name", "mrn",
      "phone", "state", "updated_at", "zip"
    ]
  end
end
EOF

info "Generating Patient type in GraphQL..."
bin/rails generate graphql:object Patient

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
