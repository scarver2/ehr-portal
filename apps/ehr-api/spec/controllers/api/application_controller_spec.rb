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

  # ── current_user session deserialization ──────────────────────────────────

  describe "#current_user" do
    context "with Devise 5 hash format ({ 'id' => id, 'token' => ... })" do
      before { session["warden.user.user.key"] = { "id" => user.id, "token" => "x" } }

      it "returns the user (line 23 — Hash branch)" do
        get :index
        expect(response.parsed_body["user_id"]).to eq(user.id)
      end
    end

    context "with Devise < 5 array format ([[id], salt])" do
      before { session["warden.user.user.key"] = [[user.id], "salt"] }

      it "returns the user (line 22 — Array branch)" do
        get :index
        expect(response.parsed_body["user_id"]).to eq(user.id)
      end
    end

    context "when the user id in the session does not match any record" do
      before { session["warden.user.user.key"] = { "id" => 0, "token" => "x" } }

      it "resolves to nil" do
        get :index
        expect(response.parsed_body["user_id"]).to be_nil
      end
    end
  end

  # ── authenticate_api_user! ────────────────────────────────────────────────

  describe "#authenticate_api_user!" do
    context "when no session key is present" do
      it "returns 401 Unauthorized" do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Unauthorized")
      end
    end

    context "when the session user id does not exist" do
      before { session["warden.user.user.key"] = { "id" => 0, "token" => "x" } }

      it "returns 401 Unauthorized" do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when a valid session is present" do
      before { session["warden.user.user.key"] = { "id" => user.id, "token" => "x" } }

      it "allows the request through" do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
