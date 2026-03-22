# spec/controllers/api/application_controller_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ApplicationController, type: :controller do
  # Anonymous subclass with a minimal action so we can hit the controller
  controller do
    def index
      render json: { user_id: current_user&.id }
    end
  end

  let(:user) { create(:user, :patient) }

  def jwt_header_for(user)
    secret = Rails.application.credentials.secret_key_base
    payload = {
      sub:   user.id.to_s,
      email: user.email,
      iat:   Time.current.to_i,
      exp:   (Time.current + 1.day).to_i,
      iss:   "ehr-portal-api"
    }
    token = JWT.encode(payload, secret, "HS256")
    { "Authorization" => "Bearer #{token}" }
  end

  # ── current_user JWT resolution ───────────────────────────────────────────

  describe "#current_user" do
    context "with a valid JWT Bearer token" do
      before { request.headers.merge!(jwt_header_for(user)) }

      it "returns the authenticated user" do
        get :index
        expect(response.parsed_body["user_id"]).to eq(user.id)
      end
    end

    context "when no Authorization header is present" do
      it "resolves to nil (returns 401)" do
        get :index
        expect(response.parsed_body["user_id"]).to be_nil
      end
    end

    context "with a malformed token" do
      before { request.headers["Authorization"] = "Bearer not.a.valid.jwt" }

      it "resolves to nil (returns 401)" do
        get :index
        expect(response.parsed_body["user_id"]).to be_nil
      end
    end

    context "when the token references a user whose account is not verified" do
      before do
        user.account.update!(status: "unverified")
        request.headers.merge!(jwt_header_for(user))
      end

      it "resolves to nil (returns 401)" do
        get :index
        expect(response.parsed_body["user_id"]).to be_nil
      end
    end
  end

  # ── authenticate_api_user! ────────────────────────────────────────────────

  describe "#authenticate_api_user!" do
    context "when no token is present" do
      it "returns 401 Unauthorized" do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Unauthorized")
      end
    end

    context "when an invalid token is provided" do
      before { request.headers["Authorization"] = "Bearer invalid.token.here" }

      it "returns 401 Unauthorized" do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when a valid JWT token is provided" do
      before { request.headers.merge!(jwt_header_for(user)) }

      it "allows the request through" do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
