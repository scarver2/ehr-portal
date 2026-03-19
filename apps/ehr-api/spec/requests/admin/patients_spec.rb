# spec/requests/admin/patients_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Patients", type: :request do
  context "when not authenticated" do
    it "redirects to login" do
      get "/admin/patients"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  %i[provider staff patient].each do |role|
    context "when authenticated as #{role}" do
      before { sign_in create(:user, role) }

      it "signs out and redirects to login" do
        get "/admin/patients"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context "when authenticated as admin" do
    let(:admin_user) { create(:user, :admin) }

    before { sign_in admin_user }

    describe "GET /admin/patients" do
      let!(:patient) { create(:patient) }

      it "returns ok" do
        get "/admin/patients"
        expect(response).to have_http_status(:ok)
      end

      it "lists patients" do
        get "/admin/patients"
        expect(response.body).to include(patient.last_name)
      end
    end

    describe "GET /admin/patients/new" do
      it "returns ok" do
        get "/admin/patients/new"
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/patients" do
      let(:valid_params) do
        {
          patient: {
            first_name:   "Jane",
            last_name:    "Doe",
            mrn:          "99887766",
            date_of_birth: "1990-03-15",
            gender:        "female"
          }
        }
      end

      it "creates a patient" do
        expect {
          post "/admin/patients", params: valid_params
        }.to change(Patient, :count).by(1)
      end

      it "redirects to the new patient" do
        post "/admin/patients", params: valid_params
        expect(response).to redirect_to(admin_patient_path(Patient.last))
      end
    end

    describe "GET /admin/patients/:id" do
      let(:patient) { create(:patient) }

      it "returns ok" do
        get "/admin/patients/#{patient.id}"
        expect(response).to have_http_status(:ok)
      end

      it "shows patient details" do
        get "/admin/patients/#{patient.id}"
        expect(response.body).to include(
          CGI.escapeHTML(patient.first_name),
          CGI.escapeHTML(patient.last_name)
        )
      end
    end

    describe "GET /admin/patients/:id/edit" do
      let(:patient) { create(:patient) }

      it "returns ok" do
        get "/admin/patients/#{patient.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PATCH /admin/patients/:id" do
      let(:patient) { create(:patient) }

      it "updates the patient and redirects" do
        patch "/admin/patients/#{patient.id}", params: { patient: { first_name: "Updated" } }
        expect(patient.reload.first_name).to eq("Updated")
        expect(response).to redirect_to(admin_patient_path(patient))
      end
    end

    describe "DELETE /admin/patients/:id" do
      let!(:patient) { create(:patient, :without_user) }

      it "deletes the patient" do
        expect {
          delete "/admin/patients/#{patient.id}"
        }.to change(Patient, :count).by(-1)
      end

      it "redirects to index" do
        delete "/admin/patients/#{patient.id}"
        expect(response).to redirect_to(admin_patients_path)
      end
    end
  end
end
