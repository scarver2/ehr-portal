# spec/models/payer_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payer, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:payer_code) }
  end

  describe "associations" do
    it { is_expected.to have_many(:insurance_profiles) }
  end

  describe ".active scope" do
    let!(:active_payer)   { create(:payer, active: true) }
    let!(:inactive_payer) { create(:payer, :inactive) }

    it "returns only active payers" do
      expect(described_class.active).to include(active_payer)
      expect(described_class.active).not_to include(inactive_payer)
    end
  end

  describe "#simulated_latency" do
    it "converts response_time_ms to seconds" do
      payer = build(:payer, response_time_ms: 1500)
      expect(payer.simulated_latency).to eq(1.5)
    end

    it "defaults to 1.5 when response_time_ms is nil" do
      payer = build(:payer, response_time_ms: nil)
      expect(payer.simulated_latency).to eq(1.5)
    end
  end
end
