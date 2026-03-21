# spec/requests/admin/diagnoses_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Diagnoses", type: :request do
  context "when not authenticated" do
    it "redirects to login" do
      get "/admin/diagnoses"
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context "when authenticated as admin" do
    let(:admin_user) { create(:admin_user) }
    let(:encounter)  { create(:encounter) }

    before { sign_in admin_user }

    describe "GET /admin/diagnoses" do
      let!(:diagnosis) { create(:diagnosis, :active, encounter: encounter) }

      it "returns ok" do
        get "/admin/diagnoses"
        expect(response).to have_http_status(:ok)
      end

      it "lists diagnoses" do
        get "/admin/diagnoses"
        expect(response.body).to include(CGI.escapeHTML(diagnosis.icd10_code))
      end
    end

    describe "GET /admin/diagnoses/new" do
      it "returns ok" do
        get "/admin/diagnoses/new"
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/diagnoses" do
      let(:valid_params) do
        {
          diagnosis: {
            encounter_id: encounter.id,
            icd10_code:   "I10",
            description:  "Essential hypertension",
            status:       "active",
            diagnosed_at: Date.today
          }
        }
      end

      it "creates a diagnosis" do
        expect {
          post "/admin/diagnoses", params: valid_params
        }.to change(Diagnosis, :count).by(1)
      end

      it "redirects to the new diagnosis" do
        post "/admin/diagnoses", params: valid_params
        expect(response).to redirect_to(admin_diagnosis_path(Diagnosis.last))
      end
    end

    describe "GET /admin/diagnoses/:id" do
      let(:diagnosis) { create(:diagnosis, :hypertension, encounter: encounter) }

      it "returns ok" do
        get "/admin/diagnoses/#{diagnosis.id}"
        expect(response).to have_http_status(:ok)
      end

      it "shows diagnosis details" do
        get "/admin/diagnoses/#{diagnosis.id}"
        expect(response.body).to include(
          CGI.escapeHTML(diagnosis.icd10_code),
          CGI.escapeHTML(diagnosis.description)
        )
      end
    end

    describe "GET /admin/diagnoses/:id/edit" do
      let(:diagnosis) { create(:diagnosis, encounter: encounter) }

      it "returns ok" do
        get "/admin/diagnoses/#{diagnosis.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PATCH /admin/diagnoses/:id" do
      let(:diagnosis) { create(:diagnosis, :active, encounter: encounter, description: "Original") }

      it "updates the diagnosis and redirects" do
        patch "/admin/diagnoses/#{diagnosis.id}", params: { diagnosis: { description: "Updated description" } }
        expect(diagnosis.reload.description).to eq("Updated description")
        expect(response).to redirect_to(admin_diagnosis_path(diagnosis))
      end
    end

    describe "DELETE /admin/diagnoses/:id" do
      let!(:diagnosis) { create(:diagnosis, encounter: encounter) }

      it "deletes the diagnosis" do
        expect {
          delete "/admin/diagnoses/#{diagnosis.id}"
        }.to change(Diagnosis, :count).by(-1)
      end

      it "redirects to index" do
        delete "/admin/diagnoses/#{diagnosis.id}"
        expect(response).to redirect_to(admin_diagnoses_path)
      end
    end
  end
end
