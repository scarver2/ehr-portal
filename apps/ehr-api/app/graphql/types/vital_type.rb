# apps/ehr-api/app/graphql/types/vital_type.rb
# frozen_string_literal: true

module Types
  class VitalType < Types::BaseObject
    description "A vital sign measurement recorded during an encounter."
    implements Types::NodeType

    field :id,          ID,                              null: false
    field :vital_type,  String,                          null: false
    field :value,       String,                          null: false
    field :unit,        String
    field :observed_at, GraphQL::Types::ISO8601DateTime, null: false
    field :notes,       String
    field :created_at,  GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at,  GraphQL::Types::ISO8601DateTime, null: false

    field :encounter, Types::EncounterType, null: false
  end
end
