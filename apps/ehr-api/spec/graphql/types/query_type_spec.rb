# spec/graphql/types/query_type_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  subject(:fields) { described_class.fields }

  it {
    expect(subject).to include(
      'patients', 'patient',
      'providers', 'provider',
      'specialties', 'specialty',
      'encounters', 'encounter',
      'vitals', 'diagnoses'
    )
  }

  # ── providers ──────────────────────────────────────────────────────────────

  describe 'providers field' do
    subject(:field) { described_class.fields['providers'] }

    its(:name) { is_expected.to eq('providers') }

    it 'returns a list type' do
      expect(field.type.list?).to be true
    end
  end

  describe 'provider field' do
    subject(:field) { described_class.fields['provider'] }

    its(:name) { is_expected.to eq('provider') }

    it 'accepts an id argument' do
      expect(field.arguments.keys).to include('id')
    end
  end

  # ── patients ───────────────────────────────────────────────────────────────

  describe 'patients field' do
    subject(:field) { described_class.fields['patients'] }

    it 'returns a list type' do
      expect(field.type.list?).to be true
    end

    it 'accepts a name argument' do
      expect(field.arguments.keys).to include('name')
    end

    it 'accepts a gender argument' do
      expect(field.arguments.keys).to include('gender')
    end
  end

  describe 'patient field' do
    subject(:field) { described_class.fields['patient'] }

    it 'accepts an id argument' do
      expect(field.arguments.keys).to include('id')
    end
  end

  describe '#patients resolver' do
    subject(:result) do
      EhrApiSchema.execute('{ patients { firstName lastName } }', context: {})
    end

    let!(:patient) { create(:patient, first_name: 'Alice', last_name: 'Smith') }

    it 'returns no errors' do
      expect(result['errors']).to be_nil
    end

    it 'includes the patient' do
      names = result.dig('data', 'patients').pluck('firstName')
      expect(names).to include('Alice')
    end

    it 'filters by name' do
      result = EhrApiSchema.execute(
        '{ patients(name: "Alice") { firstName } }',
        context: {}
      )
      names = result.dig('data', 'patients').pluck('firstName')
      expect(names).to include('Alice')
    end
  end

  # ── specialties ────────────────────────────────────────────────────────────

  describe 'specialties field' do
    subject(:field) { described_class.fields['specialties'] }

    it 'returns a list type' do
      expect(field.type.list?).to be true
    end

    it 'accepts a category argument' do
      expect(field.arguments.keys).to include('category')
    end
  end

  describe 'specialty field' do
    subject(:field) { described_class.fields['specialty'] }

    it 'accepts an id argument' do
      expect(field.arguments.keys).to include('id')
    end
  end

  describe '#specialties resolver' do
    let!(:specialty) { create(:specialty, name: 'Cardiology', category: 'Medical') }

    it 'returns all specialties' do
      result = EhrApiSchema.execute('{ specialties { name } }', context: {})
      expect(result['errors']).to be_nil
      names = result.dig('data', 'specialties').pluck('name')
      expect(names).to include('Cardiology')
    end

    it 'filters by category' do
      result = EhrApiSchema.execute(
        '{ specialties(category: "Medical") { name } }',
        context: {}
      )
      names = result.dig('data', 'specialties').pluck('name')
      expect(names).to include('Cardiology')
    end

    it 'returns empty when category does not match' do
      result = EhrApiSchema.execute(
        '{ specialties(category: "Veterinary") { name } }',
        context: {}
      )
      expect(result.dig('data', 'specialties')).to be_empty
    end
  end

  # ── encounters ─────────────────────────────────────────────────────────────

  describe 'encounters field' do
    subject(:field) { described_class.fields['encounters'] }

    it 'returns a list type' do
      expect(field.type.list?).to be true
    end

    it 'accepts a patientId argument' do
      expect(field.arguments.keys).to include('patientId')
    end

    it 'accepts a providerId argument' do
      expect(field.arguments.keys).to include('providerId')
    end

    it 'accepts a status argument' do
      expect(field.arguments.keys).to include('status')
    end
  end

  describe 'encounter field' do
    subject(:field) { described_class.fields['encounter'] }

    it 'accepts an id argument' do
      expect(field.arguments.keys).to include('id')
    end
  end

  describe '#encounters resolver' do
    let!(:encounter) { create(:encounter) }

    it 'returns all encounters' do
      result = EhrApiSchema.execute('{ encounters { id status } }', context: {})
      expect(result['errors']).to be_nil
      ids = result.dig('data', 'encounters').pluck('id')
      expect(ids).to include(encounter.id.to_s)
    end

    it 'filters by patientId' do
      result = EhrApiSchema.execute(
        "{ encounters(patientId: \"#{encounter.patient_id}\") { id } }",
        context: {}
      )
      ids = result.dig('data', 'encounters').pluck('id')
      expect(ids).to include(encounter.id.to_s)
    end

    it 'filters by status' do
      result = EhrApiSchema.execute(
        "{ encounters(status: \"#{encounter.status}\") { id } }",
        context: {}
      )
      expect(result['errors']).to be_nil
    end
  end

  # ── vitals ─────────────────────────────────────────────────────────────────

  describe 'vitals field' do
    subject(:field) { described_class.fields['vitals'] }

    it 'returns a list type' do
      expect(field.type.list?).to be true
    end

    it 'requires an encounterId argument' do
      arg = field.arguments['encounterId']
      expect(arg).to be_present
      expect(arg.type.non_null?).to be true
    end
  end

  describe '#vitals resolver' do
    let!(:vital) { create(:vital, :blood_pressure) }

    it 'returns vitals for an encounter' do
      result = EhrApiSchema.execute(
        "{ vitals(encounterId: \"#{vital.encounter_id}\") { vitalType value } }",
        context: {}
      )
      expect(result['errors']).to be_nil
      types = result.dig('data', 'vitals').pluck('vitalType')
      expect(types).to include('blood_pressure')
    end

    it 'returns empty for an encounter with no vitals' do
      other_encounter = create(:encounter)
      result = EhrApiSchema.execute(
        "{ vitals(encounterId: \"#{other_encounter.id}\") { vitalType } }",
        context: {}
      )
      expect(result.dig('data', 'vitals')).to be_empty
    end
  end

  # ── diagnoses ──────────────────────────────────────────────────────────────

  describe 'diagnoses field' do
    subject(:field) { described_class.fields['diagnoses'] }

    it 'returns a list type' do
      expect(field.type.list?).to be true
    end

    it 'accepts an encounterId argument' do
      expect(field.arguments.keys).to include('encounterId')
    end

    it 'accepts an icd10Code argument' do
      expect(field.arguments.keys).to include('icd10Code')
    end
  end

  describe '#diagnoses resolver' do
    let!(:diagnosis) { create(:diagnosis, :hypertension) }

    it 'returns all diagnoses when no filters are given' do
      result = EhrApiSchema.execute('{ diagnoses { icd10Code } }', context: {})
      expect(result['errors']).to be_nil
      codes = result.dig('data', 'diagnoses').pluck('icd10Code')
      expect(codes).to include(diagnosis.icd10_code)
    end

    it 'filters by encounterId' do
      result = EhrApiSchema.execute(
        "{ diagnoses(encounterId: \"#{diagnosis.encounter_id}\") { icd10Code } }",
        context: {}
      )
      codes = result.dig('data', 'diagnoses').pluck('icd10Code')
      expect(codes).to include(diagnosis.icd10_code)
    end

    it 'filters by icd10Code' do
      result = EhrApiSchema.execute(
        "{ diagnoses(icd10Code: \"#{diagnosis.icd10_code}\") { icd10Code } }",
        context: {}
      )
      codes = result.dig('data', 'diagnoses').pluck('icd10Code')
      expect(codes).to include(diagnosis.icd10_code)
    end
  end
end
