# spec/models/insurance_verification_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe InsuranceVerification, type: :model do
  describe "associations" do
    it "belongs to user (required)" do
      verification = build(:insurance_verification, user: nil)
      expect(verification).not_to be_valid
    end

    it "belongs to insurance_profile (required)" do
      verification = build(:insurance_verification, insurance_profile: nil)
      expect(verification).not_to be_valid
    end
  end

  describe "validations" do
    it "requires request_uuid" do
      verification = create(:insurance_verification)
      verification.request_uuid = nil
      expect(verification).not_to be_valid
    end

    it "validates uniqueness of request_uuid" do
      existing = create(:insurance_verification)
      duplicate = build(:insurance_verification, request_uuid: existing.request_uuid)
      expect(duplicate).not_to be_valid
    end
  end

  describe "before_validation :ensure_request_uuid" do
    it "auto-generates a UUID on create" do
      verification = build(:insurance_verification, request_uuid: nil)
      verification.valid?
      expect(verification.request_uuid).to match(/\A[0-9a-f-]{36}\z/)
    end

    it "does not overwrite a provided UUID" do
      uuid = SecureRandom.uuid
      verification = build(:insurance_verification, request_uuid: uuid)
      verification.valid?
      expect(verification.request_uuid).to eq(uuid)
    end
  end

  describe "AASM state machine" do
    subject(:verification) { create(:insurance_verification) }

    it "starts in pending state" do
      expect(verification).to be_pending
    end

    it "transitions pending → queued via enqueue!" do
      verification.enqueue!
      expect(verification).to be_queued
    end

    it "transitions queued → requesting via start_request!" do
      verification.enqueue!
      verification.start_request!
      expect(verification).to be_requesting
    end

    it "transitions requesting → parsing via start_parsing!" do
      verification.enqueue!
      verification.start_request!
      verification.start_parsing!
      expect(verification).to be_parsing
    end

    it "transitions parsing → verified via mark_verified!" do
      verification.enqueue!
      verification.start_request!
      verification.start_parsing!
      verification.mark_verified!
      expect(verification).to be_verified
    end

    it "transitions requesting → verified directly via mark_verified!" do
      verification.enqueue!
      verification.start_request!
      verification.mark_verified!
      expect(verification).to be_verified
    end

    it "transitions queued → failed via mark_failed!" do
      verification.enqueue!
      verification.mark_failed!
      expect(verification).to be_failed
    end

    it "transitions verified → expired via mark_expired!" do
      verification.enqueue!
      verification.start_request!
      verification.mark_verified!
      verification.mark_expired!
      expect(verification).to be_expired
    end

    it "transitions pending → canceled via cancel!" do
      verification.cancel!
      expect(verification).to be_canceled
    end

    it "does not allow invalid transitions" do
      expect { verification.start_request! }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe "#broadcast!" do
    it "broadcasts to the InsuranceVerificationChannel" do
      verification = create(:insurance_verification, :verified)
      expect(InsuranceVerificationChannel).to receive(:broadcast_to).with(
        verification.user,
        hash_including(id: verification.id, status: "verified")
      )
      verification.broadcast!
    end
  end
end
