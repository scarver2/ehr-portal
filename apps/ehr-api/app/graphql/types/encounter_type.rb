# apps/ehr-api/app/graphql/types/encounter_type.rb
# frozen_string_literal: true

module Types
  class EncounterType < Types::BaseObject
    description 'A clinical encounter between a patient and provider.'
    implements Types::NodeType

    field :chief_complaint, String
    field :created_at,      GraphQL::Types::ISO8601DateTime, null: false
    field :encounter_type,  String, null: false
    field :encountered_at,  GraphQL::Types::ISO8601DateTime, null: false
    field :id,              ID,                              null: false
    field :notes,           String
    field :status,          String,                          null: false
    field :updated_at,      GraphQL::Types::ISO8601DateTime, null: false

    field :diagnoses,  [Types::DiagnosisType], null: false
    field :patient,    Types::PatientType, null: false
    field :provider,   Types::ProviderType,        null: false
    field :vitals,     [Types::VitalType],         null: false

    def vitals
      object.vitals.recent
    end

    def diagnoses
      object.diagnoses.recent
    end
  end
end
