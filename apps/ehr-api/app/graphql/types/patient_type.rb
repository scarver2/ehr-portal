# apps/ehr-api/app/graphql/types/patient_type.rb
# frozen_string_literal: true

module Types
  class PatientType < Types::BaseObject
    description "A patient receiving care."
    implements Types::NodeType

    field :id,                       ID,                              null: false
    field :first_name,               String,                          null: false
    field :last_name,                String,                          null: false
    field :full_name,                String,                          null: false
    field :date_of_birth,            GraphQL::Types::ISO8601Date,     null: true
    field :age,                      Integer,                         null: true
    field :gender,                   String,                          null: true
    field :mrn,                      String,                          null: true
    field :phone,                    String,                          null: true
    field :address,                  String,                          null: true
    field :emergency_contact_name,   String,                          null: true
    field :emergency_contact_phone,  String,                          null: true
    field :created_at,               GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at,               GraphQL::Types::ISO8601DateTime, null: false

    field :encounters, [Types::EncounterType], null: false

    def encounters
      object.encounters.recent
    end
  end
end
