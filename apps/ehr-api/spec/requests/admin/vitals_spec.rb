# spec/requests/admin/vitals_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Vitals' do
  context 'when not authenticated' do
    it 'redirects to login' do
      get '/admin/vitals'
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when authenticated as admin' do
    let(:admin_user) { create(:admin_user) }
    let(:encounter)  { create(:encounter) }

    before { sign_in admin_user }

    describe 'GET /admin/vitals' do
      let!(:vital) { create(:vital, :heart_rate, encounter: encounter) }

      it 'returns ok' do
        get '/admin/vitals'
        expect(response).to have_http_status(:ok)
      end

      it 'lists vitals' do
        get '/admin/vitals'
        expect(response.body).to include('heart_rate')
      end
    end

    describe 'GET /admin/vitals/new' do
      it 'returns ok' do
        get '/admin/vitals/new'
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /admin/vitals' do
      let(:valid_params) do
        {
          vital: {
            encounter_id: encounter.id,
            vital_type: 'heart_rate',
            value: '72',
            unit: 'bpm',
            observed_at: 1.hour.ago
          }
        }
      end

      it 'creates a vital' do
        expect do
          post '/admin/vitals', params: valid_params
        end.to change(Vital, :count).by(1)
      end

      it 'redirects to the new vital' do
        post '/admin/vitals', params: valid_params
        expect(response).to redirect_to(admin_vital_path(Vital.last))
      end
    end

    describe 'GET /admin/vitals/:id' do
      let(:vital) { create(:vital, :blood_pressure, encounter: encounter) }

      it 'returns ok' do
        get "/admin/vitals/#{vital.id}"
        expect(response).to have_http_status(:ok)
      end

      it 'shows vital details' do
        get "/admin/vitals/#{vital.id}"
        expect(response.body).to include('blood_pressure')
      end
    end

    describe 'GET /admin/vitals/:id/edit' do
      let(:vital) { create(:vital, encounter: encounter) }

      it 'returns ok' do
        get "/admin/vitals/#{vital.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /admin/vitals/:id' do
      let(:vital) { create(:vital, :heart_rate, encounter: encounter, value: '70') }

      it 'updates the vital and redirects' do
        patch "/admin/vitals/#{vital.id}", params: { vital: { value: '80' } }
        expect(vital.reload.value).to eq('80')
        expect(response).to redirect_to(admin_vital_path(vital))
      end
    end

    describe 'DELETE /admin/vitals/:id' do
      let!(:vital) { create(:vital, encounter: encounter) }

      it 'deletes the vital' do
        expect do
          delete "/admin/vitals/#{vital.id}"
        end.to change(Vital, :count).by(-1)
      end

      it 'redirects to index' do
        delete "/admin/vitals/#{vital.id}"
        expect(response).to redirect_to(admin_vitals_path)
      end
    end
  end
end
