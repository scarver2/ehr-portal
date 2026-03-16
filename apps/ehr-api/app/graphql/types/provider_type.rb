# apps/ehr-api/app/graphql/types/provider_type.rb
# frozen_string_literal: true

module Types
  class ProviderType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String
    field :last_name, String
    field :full_name, String
    field :npi, String
    field :specialty, String
    field :clinic_name, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def full_name
      "#{object.first_name} #{object.last_name}"
    end
  end
end
