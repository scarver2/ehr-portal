# apps/ehr-api/app/graphql/types/provider_type.rb
# frozen_string_literal: true

module Types
  class ProviderType < Types::BaseObject
    description 'A healthcare provider.'
    implements Types::NodeType

    field :city, String
    field :clinic_name, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :encounters, [Types::EncounterType], null: false, description: 'All encounters for this provider.'
    field :first_name, String
    field :full_name,  String, null: false
    field :id,         ID, null: false
    field :last_name,  String
    field :location,   String, null: true, description: 'City and state joined for display.'
    field :npi,        String
    field :photo_url,  String, null: true, description: "URL to provider's profile photo headshot."
    field :specialty,  Types::SpecialtyType, null: true
    field :state,      String
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :zip,        String

    def full_name
      "#{object.first_name} #{object.last_name}"
    end
  end
end
