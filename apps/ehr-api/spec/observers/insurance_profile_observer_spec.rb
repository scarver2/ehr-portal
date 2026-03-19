# spec/observers/insurance_profile_observer_spec.rb
# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe InsuranceProfileObserver, type: :model do
  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  describe "after_create" do
    let(:user)  { create(:user, :patient) }
    let(:payer) { create(:payer) }

    it "creates an InsuranceVerification for the profile" do
      expect {
        create(:insurance_profile, user: user, payer: payer)
      }.to change(InsuranceVerification, :count).by(1)
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
