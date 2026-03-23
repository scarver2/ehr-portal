# spec/services/fake_payer_gateway_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FakePayerGateway do
  subject(:gateway) { described_class.new(verification) }

  let(:user)         { create(:user, :patient) }
  let(:payer)        { create(:payer) }
  let(:profile)      { create(:insurance_profile, user: user, payer: payer) }
  let(:verification) { create(:insurance_verification, :queued, user: user, insurance_profile: profile) }

  describe '#check_eligibility' do
    subject(:response) { gateway.check_eligibility }

    before { allow(gateway).to receive(:sleep) }

    it 'returns a reference_id' do
      expect(response[:reference_id]).to be_a(String)
    end

    it 'returns payer_name' do
      expect(response[:payer_name]).to be_a(String)
    end

    it 'returns plan_name' do
      expect(response[:plan_name]).to be_a(String)
    end

    it 'returns copay_cents as an integer' do
      expect(response[:copay_cents]).to be_a(Integer)
    end

    it 'returns deductible_cents as an integer' do
      expect(response[:deductible_cents]).to be_a(Integer)
    end

    it 'returns oop_max_cents as an integer' do
      expect(response[:oop_max_cents]).to be_a(Integer)
    end

    it 'returns eligibility active' do
      expect(response[:eligibility]).to eq('active')
    end

    it 'returns a benefits hash' do
      expect(response[:benefits]).to include(:primary_care, :specialist, :telehealth)
    end
  end
end
