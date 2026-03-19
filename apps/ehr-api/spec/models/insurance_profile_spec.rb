# spec/models/insurance_profile_spec.rb
# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe InsuranceProfile, type: :model do
  describe "associations" do
    it "belongs to user (required)" do
      profile = build(:insurance_profile, user: nil)
      expect(profile).not_to be_valid
    end

    it "belongs to payer optionally" do
      assoc = described_class.reflect_on_association(:payer)
      expect(assoc.options[:optional]).to be true
    end

    it "has many insurance_verifications destroyed with profile" do
      assoc = described_class.reflect_on_association(:insurance_verifications)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end
  end

  describe "validations" do
    it "requires member_id" do
      profile = build(:insurance_profile, member_id: nil)
      expect(profile).not_to be_valid
    end

    it "requires payer_name" do
      profile = build(:insurance_profile, payer_name: nil)
      expect(profile).not_to be_valid
    end
  end

  describe "defaults" do
    it "defaults status to pending" do
      profile = described_class.new
      expect(profile.status).to eq("pending")
    end
  end

  describe "after_create_commit" do
    let(:user)  { create(:user, :patient) }
    let(:payer) { create(:payer) }

    around { |example| Sidekiq::Testing.fake! { example.run } }

    before { allow(InsuranceVerificationChannel).to receive(:broadcast_to) }

    it "creates an InsuranceVerification" do
      expect do
        create(:insurance_profile, user: user, payer: payer)
      end.to change(InsuranceVerification, :count).by(1)
    end

    it "enqueues an InsuranceVerificationWorker job" do
      Sidekiq::Worker.clear_all
      create(:insurance_profile, user: user, payer: payer)
      expect(InsuranceVerificationWorker.jobs.size).to eq(1)
    end

    it "sets verification status to queued" do
      create(:insurance_profile, user: user, payer: payer)
      expect(user.insurance_verifications.last.status).to eq("queued")
    end
  end
end
