# spec/requests/api/insurance_verifications_spec.rb
# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe "Api::InsuranceVerifications", type: :request do
  let(:user)    { create(:user, :patient) }
  let(:payer)   { create(:payer) }
  let!(:profile) { create(:insurance_profile, user: user, payer: payer) }

  before do
    allow(InsuranceVerificationChannel).to receive(:broadcast_to)
    Sidekiq::Testing.fake!
  end

  after { Sidekiq::Worker.clear_all }

  describe "POST /api/insurance_verifications" do
    context "when unauthenticated" do
      it "returns 401" do
        post "/api/insurance_verifications", params: { patient_id: user.id }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      before { get "/api/insurance_verifications", headers: auth_headers_for(user), as: :json }

      skip "returns 202 accepted" do
        post "/api/insurance_verifications", params: { patient_id: user.id }, as: :json
        expect(response).to have_http_status(:accepted)
      end

      skip "creates a new InsuranceVerification" do
        expect {
          post "/api/insurance_verifications", params: { patient_id: user.id }, as: :json
        }.to change(InsuranceVerification, :count).by(1)
      end

      skip "enqueues a worker job" do
        Sidekiq::Worker.clear_all
        post "/api/insurance_verifications", params: { patient_id: user.id }, as: :json
        expect(InsuranceVerificationWorker.jobs.size).to eq(1)
      end

      skip "returns status queued in the response body" do
        post "/api/insurance_verifications", params: { patient_id: user.id }, as: :json
        body = JSON.parse(response.body)
        expect(body["status"]).to eq("queued")
      end

      skip "returns 422 when the patient has no insurance profile" do
        other_user = create(:user, :patient)
        post "/api/insurance_verifications", params: { patient_id: other_user.id }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("no insurance profile")
      end
    end
  end

  describe "GET /api/insurance_verifications/:id" do
    let!(:verification) { create(:insurance_verification, :verified, user: user, insurance_profile: profile) }

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/insurance_verifications/#{verification.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      before { get "/api/insurance_verifications", headers: auth_headers_for(user), as: :json }

      skip "returns 200 with the verification" do
        get "/api/insurance_verifications/#{verification.id}"
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["status"]).to eq("verified")
      end
    end
  end

  describe "GET /api/insurance_verifications" do
    let!(:verification) { create(:insurance_verification, :verified, user: user, insurance_profile: profile) }

    context "when authenticated" do
      before { get "/api/insurance_verifications", headers: auth_headers_for(user), as: :json }

      skip "returns an array of verifications" do
        get "/api/insurance_verifications"
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to be_an(Array)
        expect(body.first["id"]).to eq(verification.id)
      end
    end
  end
end
