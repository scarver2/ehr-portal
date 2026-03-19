# apps/ehr-api/app/graphql/types/diagnosis_type.rb
# frozen_string_literal: true

module Types
  class DiagnosisType < Types::BaseObject
    description "A clinical diagnosis recorded during an encounter."
    implements Types::NodeType

    field :id,           ID,                              null: false
    field :icd10_code,   String,                          null: false
    field :description,  String,                          null: false
    field :status,       String,                          null: false
    field :diagnosed_at, GraphQL::Types::ISO8601DateTime, null: false
    field :notes,        String
    field :created_at,   GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at,   GraphQL::Types::ISO8601DateTime, null: false

    field :encounter, Types::EncounterType, null: false
  end
end
