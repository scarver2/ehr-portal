# bin/steps/31_providers_modeling.sh

# Schema:
# first_name:string
# last_name:string
# npi: string
# specialty: string
# clinic_name: string

# Proposed additional fields:
# taxonomy:string
# address:string
# phone:string
# email:string
# website:string

# Steps:
# 1. Generate Provider model in Rails
# 2. Generate Provider resource in ActiveAdmin
# 3. Generate Provider type in GraphQL

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Generating Provider model..."
bin/rails generate model Provider first_name:string last_name:string npi:string specialty:string clinic_name:string

info "Generating Provider resource in ActiveAdmin..."
# bin/rails generate active_admin:resource Provider
# To avoid a premature database migration, we'll create the resource manually

cat << 'EOF' > apps/ehr-api/app/admin/providers.rb
# apps/ehr-api/app/admin/providers.rb

ActiveAdmin.register Provider do
  permit_params :first_name, :last_name, :npi, :specialty, :clinic_name
end
EOF

info "Adding Ransackable attributes to Provider model..."
cat << 'EOF' > apps/ehr-api/app/models/provider.rb
# apps/ehr-api/app/models/provider.rb
# frozen_string_literal: true

class Provider < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["clinic_name", "created_at", "first_name", "id", "id_value", "last_name", "npi", "specialty", "updated_at"]
  end
end
EOF

info "Generating Provider type in GraphQL..."
bin/rails generate graphql:object Provider

# TODO: add Provider specs

info "Adding Provider RBS type signature..."
cat << 'EOF' > sig/app/models/provider.rbs
# sig/app/models/provider.rbs
# Column types derived from db/schema.rb (providers table).
# AR generates attribute accessors dynamically; attr_accessor syntax avoids
# Ruby::MethodDefinitionMissing under all_error. Predicate methods (_?) are
# omitted — they exist at runtime but cannot be declared without triggering
# the same diagnostic.

class Provider < ApplicationRecord
  attr_accessor id: ::Integer
  attr_accessor first_name: ::String?
  attr_accessor last_name: ::String?
  attr_accessor npi: ::String?
  attr_accessor specialty: ::String?
  attr_accessor clinic_name: ::String?
  attr_accessor created_at: ::Time
  attr_accessor updated_at: ::Time

  def self.ransackable_attributes: (?untyped auth_object) -> ::Array[::String]
end
EOF

info "Adding Provider GraphQL type signature..."
cat << 'EOF' > sig/app/graphql/types/provider_type.rbs
# sig/app/graphql/types/provider_type.rbs

module Types
  class ProviderType < Types::BaseObject
    def full_name: () -> ::String
  end
end
EOF
