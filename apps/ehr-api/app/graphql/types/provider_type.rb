# frozen_string_literal: true

module Types
  class ProviderType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String
    field :last_name, String
    field :full_name, String
    field :specialty, String
    field :clinic, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def full_name
      "#{object.first_name} #{object.last_name}"
    end

    def specialty
      # TODO: faked
      "Family Medicine"
    end

    def clinic
      # TODO: faked
      "North Dallas Medical Group"
    end

    def npi
      # TODO: faked
      rand(1_000_000_000..9_999_999_999)
    end
  end
end
