# apps/ehr-api/app/graphql/types/specialty_type.rb
# frozen_string_literal: true

module Types
  class SpecialtyType < Types::BaseObject
    description 'A medical specialty assigned to a provider.'
    implements Types::NodeType

    field :category,   String,                          null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :id,         ID,                              null: false
    field :name,       String,                          null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
