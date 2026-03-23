# spec/graphql/types/vital_type_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::VitalType do
  subject(:fields) { described_class.fields }

  it {
    expect(subject).to include(
      'id', 'vitalType', 'value', 'unit',
      'observedAt', 'notes',
      'createdAt', 'updatedAt', 'encounter'
    )
  }

  describe 'field nullability' do
    it 'marks id as non-null' do
      expect(fields['id'].type.to_type_signature).to include('!')
    end

    it 'marks vitalType as non-null' do
      expect(fields['vitalType'].type.to_type_signature).to include('!')
    end

    it 'marks value as non-null' do
      expect(fields['value'].type.to_type_signature).to include('!')
    end

    it 'marks observedAt as non-null' do
      expect(fields['observedAt'].type.to_type_signature).to include('!')
    end

    it 'marks createdAt as non-null' do
      expect(fields['createdAt'].type.to_type_signature).to include('!')
    end

    it 'marks updatedAt as non-null' do
      expect(fields['updatedAt'].type.to_type_signature).to include('!')
    end

    it 'allows unit to be null' do
      expect(fields['unit'].type.to_type_signature).not_to end_with('!')
    end

    it 'allows notes to be null' do
      expect(fields['notes'].type.to_type_signature).not_to end_with('!')
    end
  end

  describe 'vitals query' do
    subject(:result) do
      EhrApiSchema.execute(
        "{ vitals(encounterId: \"#{encounter.id}\") { vitalType value } }",
        context: {}
      )
    end

    let(:encounter) { create(:encounter) }
    let!(:vital)    { create(:vital, :heart_rate, encounter: encounter) }

    it 'returns no errors' do
      expect(result['errors']).to be_nil
    end

    it 'returns vitals scoped to the encounter' do
      types = result.dig('data', 'vitals').pluck('vitalType')
      expect(types).to include('heart_rate')
    end
  end
end
