# spec/requests/admin/encounters_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Encounters' do
  context 'when not authenticated' do
    it 'redirects to login' do
      get '/admin/encounters'
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when authenticated as admin' do
    let(:admin_user) { create(:admin_user) }
    let(:patient)    { create(:patient) }
    let(:provider)   { create(:provider) }

    before { sign_in admin_user }

    describe 'GET /admin/encounters' do
      let!(:encounter) { create(:encounter, patient: patient, provider: provider) }

      it 'returns ok' do
        get '/admin/encounters'
        expect(response).to have_http_status(:ok)
      end

      it 'lists encounters' do
        get '/admin/encounters'
        expect(response.body).to include(encounter.encounter_type)
      end
    end

    describe 'GET /admin/encounters/new' do
      it 'returns ok' do
        get '/admin/encounters/new'
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /admin/encounters' do
      let(:valid_params) do
        {
          encounter: {
            patient_id: patient.id,
            provider_id: provider.id,
            encounter_type: 'office_visit',
            status: 'scheduled',
            encountered_at: 1.day.ago
          }
        }
      end

      it 'creates an encounter' do
        expect do
          post '/admin/encounters', params: valid_params
        end.to change(Encounter, :count).by(1)
      end

      it 'redirects to the new encounter' do
        post '/admin/encounters', params: valid_params
        expect(response).to redirect_to(admin_encounter_path(Encounter.last))
      end
    end

    describe 'GET /admin/encounters/:id' do
      let(:encounter) { create(:encounter, patient: patient, provider: provider) }

      it 'returns ok' do
        get "/admin/encounters/#{encounter.id}"
        expect(response).to have_http_status(:ok)
      end

      it 'shows encounter details' do
        get "/admin/encounters/#{encounter.id}"
        expect(response.body).to include(encounter.encounter_type, encounter.status)
      end
    end

    describe 'GET /admin/encounters/:id/edit' do
      let(:encounter) { create(:encounter) }

      it 'returns ok' do
        get "/admin/encounters/#{encounter.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /admin/encounters/:id' do
      let(:encounter) { create(:encounter, chief_complaint: 'Headache') }

      it 'updates the encounter and redirects' do
        patch "/admin/encounters/#{encounter.id}", params: { encounter: { chief_complaint: 'Updated complaint' } }
        expect(encounter.reload.chief_complaint).to eq('Updated complaint')
        expect(response).to redirect_to(admin_encounter_path(encounter))
      end
    end

    describe 'DELETE /admin/encounters/:id' do
      let!(:encounter) { create(:encounter) }

      it 'deletes the encounter' do
        expect do
          delete "/admin/encounters/#{encounter.id}"
        end.to change(Encounter, :count).by(-1)
      end

      it 'redirects to index' do
        delete "/admin/encounters/#{encounter.id}"
        expect(response).to redirect_to(admin_encounters_path)
      end
    end
  end
end
