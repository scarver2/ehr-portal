# spec/requests/admin/providers_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Providers", type: :request do
  context "when not authenticated" do
    it "redirects to login" do
      get "/admin/providers"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  %i[provider staff patient].each do |role|
    context "when authenticated as #{role}" do
      before { sign_in create(:user, role) }

      it "signs out and redirects to login" do
        get "/admin/providers"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context "when authenticated as admin" do
    let(:admin_user) { create(:admin_user) }
    let(:specialty)  { create(:specialty) }

    before { sign_in admin_user }

    describe "GET /admin/providers" do
      let!(:provider) { create(:provider) }

      it "returns ok" do
        get "/admin/providers"
        expect(response).to have_http_status(:ok)
      end

      it "lists providers" do
        get "/admin/providers"
        expect(response.body).to include(provider.last_name)
      end
    end

    describe "GET /admin/providers/new" do
      it "returns ok" do
        get "/admin/providers/new"
        expect(response).to have_http_status(:ok)
      end

      context "user select collection (line 63)" do
        let!(:provider_user) { create(:user, :provider, email: "provider@example.com") }
        let!(:admin_user2)   { create(:user, :admin,    email: "admin2@example.com") }
        let!(:patient_user)  { create(:user, :patient,  email: "patient@example.com") }

        before { get "/admin/providers/new" }

        it "includes provider-role users in the user select" do
          expect(response.body).to include("provider@example.com")
        end

        it "excludes non-provider users from the user select" do
          expect(response.body).not_to include("admin2@example.com")
          expect(response.body).not_to include("patient@example.com")
        end
      end
    end

    describe "POST /admin/providers" do
      let(:valid_params) do
        {
          provider: {
            first_name:   "Jane",
            last_name:    "Smith",
            npi:          "1234567890",
            specialty_id: specialty.id,
            clinic_name:  "General Hospital"
          }
        }
      end

      it "creates a provider" do
        expect {
          post "/admin/providers", params: valid_params
        }.to change(Provider, :count).by(1)
      end

      it "redirects to the new provider" do
        post "/admin/providers", params: valid_params
        expect(response).to redirect_to(admin_provider_path(Provider.last))
      end
    end

    describe "GET /admin/providers/:id" do
      let(:provider) { create(:provider) }

      it "returns ok" do
        get "/admin/providers/#{provider.id}"
        expect(response).to have_http_status(:ok)
      end

      it "shows provider details" do
        get "/admin/providers/#{provider.id}"
        expect(response.body).to include(
          CGI.escapeHTML(provider.first_name),
          CGI.escapeHTML(provider.last_name)
        )
      end
    end

    describe "GET /admin/providers/:id/edit" do
      let(:provider) { create(:provider) }

      it "returns ok" do
        get "/admin/providers/#{provider.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PATCH /admin/providers/:id" do
      let(:provider) { create(:provider) }

      it "updates the provider and redirects" do
        patch "/admin/providers/#{provider.id}", params: { provider: { first_name: "Updated" } }
        expect(provider.reload.first_name).to eq("Updated")
        expect(response).to redirect_to(admin_provider_path(provider))
      end
    end

    describe "DELETE /admin/providers/:id" do
      let!(:provider) { create(:provider) }

      it "deletes the provider" do
        expect {
          delete "/admin/providers/#{provider.id}"
        }.to change(Provider, :count).by(-1)
      end

      it "redirects to index" do
        delete "/admin/providers/#{provider.id}"
        expect(response).to redirect_to(admin_providers_path)
      end

      context "when the provider has encounters" do
        before { create(:encounter, provider: provider) }

        it "does not delete the provider" do
          expect {
            delete "/admin/providers/#{provider.id}"
          }.not_to change(Provider, :count)
        end
      end
    end
  end
end
