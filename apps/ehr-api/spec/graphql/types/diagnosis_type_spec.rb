# spec/graphql/types/diagnosis_type_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::DiagnosisType do
  subject(:fields) { described_class.fields }

  it {
    expect(subject).to include(
      'id', 'icd10Code', 'description', 'status',
      'diagnosedAt', 'notes',
      'createdAt', 'updatedAt', 'encounter'
    )
  }

  describe 'field nullability' do
    it 'marks id as non-null' do
      expect(fields['id'].type.to_type_signature).to include('!')
    end

    it 'marks icd10Code as non-null' do
      expect(fields['icd10Code'].type.to_type_signature).to include('!')
    end

    it 'marks description as non-null' do
      expect(fields['description'].type.to_type_signature).to include('!')
    end

    it 'marks status as non-null' do
      expect(fields['status'].type.to_type_signature).to include('!')
    end

    it 'marks diagnosedAt as non-null' do
      expect(fields['diagnosedAt'].type.to_type_signature).to include('!')
    end

    it 'marks createdAt as non-null' do
      expect(fields['createdAt'].type.to_type_signature).to include('!')
    end

    it 'marks updatedAt as non-null' do
      expect(fields['updatedAt'].type.to_type_signature).to include('!')
    end

    it 'allows notes to be null' do
      expect(fields['notes'].type.to_type_signature).not_to end_with('!')
    end
  end

  describe 'diagnoses query' do
    subject(:result) do
      EhrApiSchema.execute(
        "{ diagnoses(encounterId: \"#{encounter.id}\") { icd10Code description status } }",
        context: {}
      )
    end

    let(:encounter)  { create(:encounter) }
    let!(:diagnosis) { create(:diagnosis, :hypertension, encounter: encounter) }

    it 'returns no errors' do
      expect(result['errors']).to be_nil
    end

    it 'returns diagnoses scoped to the encounter' do
      codes = result.dig('data', 'diagnoses').pluck('icd10Code')
      expect(codes).to include(diagnosis.icd10_code)
    end

    it 'includes the status' do
      statuses = result.dig('data', 'diagnoses').pluck('status')
      expect(statuses).to include(diagnosis.status)
    end
  end
end
