# apps/ehr-api/app/graphql/types/provider_type.rb
# frozen_string_literal: true

module Types
  class ProviderType < Types::BaseObject
    description 'A healthcare provider.'
    implements Types::NodeType

    field :id,         ID,     null: false
    field :first_name, String
    field :last_name,  String
    field :full_name,  String, null: false
    field :npi,        String
    field :specialty,  Types::SpecialtyType, null: true
    field :clinic_name, String
    field :city,       String
    field :state,      String
    field :zip,        String
    field :location,   String, null: true, description: "City and state joined for display."
    field :photo_url,  String, null: true, description: "URL to provider's profile photo headshot."
    field :encounters, [Types::EncounterType], null: false, description: "All encounters for this provider."
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def full_name
      "#{object.first_name} #{object.last_name}"
    end

    def location
      object.location
    end
  end
end
