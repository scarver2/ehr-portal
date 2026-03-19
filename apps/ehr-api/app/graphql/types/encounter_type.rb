# apps/ehr-api/app/graphql/types/encounter_type.rb
# frozen_string_literal: true

module Types
  class EncounterType < Types::BaseObject
    description "A clinical encounter between a patient and provider."
    implements Types::NodeType

    field :id,              ID,                              null: false
    field :encounter_type,  String,                          null: false
    field :status,          String,                          null: false
    field :encountered_at,  GraphQL::Types::ISO8601DateTime, null: false
    field :chief_complaint, String
    field :notes,           String
    field :created_at,      GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at,      GraphQL::Types::ISO8601DateTime, null: false

    field :patient,    Types::UserType,            null: false
    field :provider,   Types::ProviderType,        null: false
    field :vitals,     [Types::VitalType],         null: false
    field :diagnoses,  [Types::DiagnosisType],     null: false

    def vitals
      object.vitals.recent
    end

    def diagnoses
      object.diagnoses.recent
    end
  end
end
