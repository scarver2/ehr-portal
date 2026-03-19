# spec/workers/insurance_verification_worker_spec.rb
# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe InsuranceVerificationWorker, type: :worker do
  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  describe "sidekiq options" do
    it "uses the insurance queue" do
      expect(described_class.get_sidekiq_options["queue"].to_s).to eq("insurance")
    end

    it "retries up to 10 times" do
      expect(described_class.get_sidekiq_options["retry"]).to eq(10)
    end
  end

  describe "#perform" do
    let(:user)         { create(:user, :patient) }
    let(:payer)        { create(:payer) }
    let(:profile)      { create(:insurance_profile, user: user, payer: payer) }
    let(:verification) { create(:insurance_verification, :queued, user: user, insurance_profile: profile) }

    before do
      # Prevent ActionCable broadcast from erroring in tests
      allow(InsuranceVerificationChannel).to receive(:broadcast_to)
    end

    context "when cache miss (normal path)" do
      before do
        allow(RteCache).to receive(:read).and_return(nil)
        allow(RteCache).to receive(:write)
        allow_any_instance_of(FakePayerGateway).to receive(:check_eligibility).and_return(
          reference_id:     "abc123",
          payer_name:       "Aetna",
          plan_name:        "Silver PPO",
          copay_cents:      2500,
          deductible_cents: 100_000,
          oop_max_cents:    500_000
        )
      end

      it "transitions verification to verified" do
        described_class.new.perform(verification.id)
        expect(verification.reload).to be_verified
      end

      it "writes result to RteCache" do
        expect(RteCache).to receive(:write).once
        described_class.new.perform(verification.id)
      end
    end

    context "when cache hit" do
      let(:cached_response) { { payer_name: "Aetna", plan_name: "Gold HMO" } }

      before do
        allow(RteCache).to receive(:read).and_return(cached_response)
      end

      it "marks verification verified without calling the gateway" do
        expect(FakePayerGateway).not_to receive(:new)
        described_class.new.perform(verification.id)
        expect(verification.reload).to be_verified
      end
    end

    context "when gateway raises an error" do
      before do
        allow(RteCache).to receive(:read).and_return(nil)
        allow_any_instance_of(FakePayerGateway).to receive(:check_eligibility)
          .and_raise(StandardError, "gateway timeout")
      end

      it "marks verification failed and re-raises" do
        expect { described_class.new.perform(verification.id) }.to raise_error(StandardError)
        expect(verification.reload).to be_failed
      end

      it "persists the error message" do
        described_class.new.perform(verification.id) rescue nil
        expect(verification.reload.error_message).to eq("gateway timeout")
      end
    end
  end
end
