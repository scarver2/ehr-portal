# spec/models/payer_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payer do
  describe 'validations' do
    it 'requires name' do
      payer = build(:payer, name: nil)
      expect(payer).not_to be_valid
    end

    it 'requires payer_code' do
      payer = build(:payer, payer_code: nil)
      expect(payer).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many insurance_profiles' do
      assoc = described_class.reflect_on_association(:insurance_profiles)
      expect(assoc.macro).to eq(:has_many)
    end
  end

  describe '.active scope' do
    let!(:active_payer)   { create(:payer, active: true) }
    let!(:inactive_payer) { create(:payer, :inactive) }

    it 'returns only active payers' do
      expect(described_class.active).to include(active_payer)
      expect(described_class.active).not_to include(inactive_payer)
    end
  end
end
