# spec/models/insurance_profile_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe InsuranceProfile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:payer).optional }
    it { is_expected.to have_many(:insurance_verifications).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:member_id) }
    it { is_expected.to validate_presence_of(:payer_name) }
  end

  describe "defaults" do
    it "defaults status to pending" do
      profile = described_class.new
      expect(profile.status).to eq("pending")
    end
  end
end
