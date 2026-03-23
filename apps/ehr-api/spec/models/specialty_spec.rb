# spec/models/specialty_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Specialty do
  subject(:specialty) { build(:specialty) }

  it { is_expected.to be_valid }

  describe 'validations' do
    context 'without a name' do
      subject { build(:specialty, name: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'with a duplicate name (case-insensitive)' do
      subject { build(:specialty, name: 'cardiology') }

      before { create(:specialty, name: 'Cardiology') }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'associations' do
    it 'has many providers' do
      s = create(:specialty)
      p = create(:provider, specialty: s)
      expect(s.providers).to include(p)
    end

    it 'nullifies providers on destroy' do
      s = create(:specialty)
      p = create(:provider, specialty: s)
      s.destroy
      expect(p.reload.specialty).to be_nil
    end
  end

  describe '.alphabetical' do
    it 'orders by name ascending' do
      z = create(:specialty, name: 'Urology')
      a = create(:specialty, name: 'Allergy & Immunology')
      expect(described_class.alphabetical.first).to eq(a)
      expect(described_class.alphabetical.last).to eq(z)
    end
  end

  describe '.by_category' do
    it 'filters by category' do
      medical  = create(:specialty, name: 'Neurology', category: 'Medical')
      surgical = create(:specialty, name: 'Urology',   category: 'Surgical')
      expect(described_class.by_category('Medical')).to include(medical)
      expect(described_class.by_category('Medical')).not_to include(surgical)
    end
  end

  describe '.ransackable_attributes' do
    it 'includes searchable fields' do
      expect(described_class.ransackable_attributes).to include('name', 'category', 'id')
    end
  end

  describe '.ransackable_associations' do
    it 'includes associated models' do
      expect(described_class.ransackable_associations).to include('providers')
    end
  end
end
