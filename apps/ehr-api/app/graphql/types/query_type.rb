# apps/ehr-api/app/graphql/types/query_type.rb
# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description 'The root query type.'

    field :node, Types::NodeType, null: true, description: 'Fetches an object given its ID.' do
      argument :id, ID, required: true, description: 'ID of the object.'
    end

    field :nodes, [Types::NodeType, { null: true }], null: true,
                                                     description: 'Fetches a list of objects given a list of IDs.' do
      argument :ids, [ID], required: true, description: 'IDs of the objects.'
    end

    # Patients
    field :patients, [Types::PatientType], null: false do
      argument :gender, String, required: false
      argument :name,   String, required: false, description: 'Full-text search on first or last name.'
    end

    field :patient, Types::PatientType, null: true do
      argument :id, ID, required: true
    end

    field :providers, [Types::ProviderType], null: false

    field :provider, Types::ProviderType, null: true do
      argument :id, ID, required: true
    end

    # Specialties
    field :specialties, [Types::SpecialtyType], null: false do
      argument :category, String, required: false
    end

    field :specialty, Types::SpecialtyType, null: true do
      argument :id, ID, required: true
    end

    # Encounters
    field :encounters, [Types::EncounterType], null: false do
      argument :patient_id,  ID,     required: false
      argument :provider_id, ID,     required: false
      argument :status,      String, required: false
    end

    field :encounter, Types::EncounterType, null: true do
      argument :id, ID, required: true
    end

    # Vitals
    field :vitals, [Types::VitalType], null: false do
      argument :encounter_id, ID, required: true
    end

    # Diagnoses
    field :diagnoses, [Types::DiagnosisType], null: false do
      argument :encounter_id, ID,     required: false
      argument :icd10_code,   String, required: false
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    def patients(name: nil, gender: nil)
      scope = Patient.alphabetical
      scope = scope.search_by_name(name) if name.present?
      scope = scope.where(gender: gender) if gender.present?
      scope
    end

    def patient(id:)
      Patient.find_by(id: id)
    end

    def providers
      Provider.order(:last_name)
    end

    def provider(id:)
      Provider.find_by(id: id)
    end

    def specialties(category: nil)
      scope = Specialty.alphabetical
      scope = scope.by_category(category) if category.present?
      scope
    end

    def specialty(id:)
      Specialty.find_by(id: id)
    end

    def encounters(patient_id: nil, provider_id: nil, status: nil)
      scope = Encounter.recent
      scope = scope.where(patient_id: patient_id)   if patient_id
      scope = scope.where(provider_id: provider_id) if provider_id
      scope = scope.where(status: status) if status
      scope
    end

    def encounter(id:)
      Encounter.find_by(id: id)
    end

    def vitals(encounter_id:)
      Vital.where(encounter_id: encounter_id).recent
    end

    def diagnoses(encounter_id: nil, icd10_code: nil)
      scope = Diagnosis.recent
      scope = scope.where(encounter_id: encounter_id) if encounter_id
      scope = scope.by_code(icd10_code)               if icd10_code
      scope
    end
  end
end
