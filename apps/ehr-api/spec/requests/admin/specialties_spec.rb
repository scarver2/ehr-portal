# spec/requests/admin/specialties_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Specialties' do
  context 'when not authenticated' do
    it 'redirects to admin login' do
      get '/admin/specialties'
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when authenticated as admin' do
    let(:admin_user) { create(:admin_user) }

    before { sign_in admin_user }

    describe 'GET /admin/specialties' do
      let!(:specialty) { create(:specialty, name: 'Cardiology', category: 'Medical') }

      it 'returns ok' do
        get '/admin/specialties'
        expect(response).to have_http_status(:ok)
      end

      it 'lists specialties' do
        get '/admin/specialties'
        expect(response.body).to include('Cardiology')
      end
    end

    describe 'GET /admin/specialties/new' do
      it 'returns ok' do
        get '/admin/specialties/new'
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /admin/specialties' do
      let(:valid_params) do
        {
          specialty: {
            name: 'Rheumatology',
            category: 'Medical'
          }
        }
      end

      it 'creates a specialty' do
        expect do
          post '/admin/specialties', params: valid_params
        end.to change(Specialty, :count).by(1)
      end

      it 'redirects to the new specialty' do
        post '/admin/specialties', params: valid_params
        expect(response).to redirect_to(admin_specialty_path(Specialty.last))
      end
    end

    describe 'GET /admin/specialties/:id' do
      let(:specialty) { create(:specialty, name: 'Neurology', category: 'Medical') }

      it 'returns ok' do
        get "/admin/specialties/#{specialty.id}"
        expect(response).to have_http_status(:ok)
      end

      it 'shows specialty details' do
        get "/admin/specialties/#{specialty.id}"
        expect(response.body).to include('Neurology', 'Medical')
      end
    end

    describe 'GET /admin/specialties/:id/edit' do
      let(:specialty) { create(:specialty) }

      it 'returns ok' do
        get "/admin/specialties/#{specialty.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /admin/specialties/:id' do
      let(:specialty) { create(:specialty, name: 'Old Name') }

      it 'updates the specialty and redirects' do
        patch "/admin/specialties/#{specialty.id}", params: { specialty: { name: 'Updated Name' } }
        expect(specialty.reload.name).to eq('Updated Name')
        expect(response).to redirect_to(admin_specialty_path(specialty))
      end
    end

    describe 'DELETE /admin/specialties/:id' do
      let!(:specialty) { create(:specialty) }

      it 'deletes the specialty' do
        expect do
          delete "/admin/specialties/#{specialty.id}"
        end.to change(Specialty, :count).by(-1)
      end

      it 'redirects to index' do
        delete "/admin/specialties/#{specialty.id}"
        expect(response).to redirect_to(admin_specialties_path)
      end
    end
  end
end
