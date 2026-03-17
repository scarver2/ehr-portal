# spec/requests/admin/providers_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Providers', type: :request do
  let(:admin_user) { create(:admin_user) }

  context 'when not authenticated' do
    it 'redirects to login' do
      get '/admin/providers'
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when authenticated' do
    before { sign_in admin_user }

    describe 'GET /admin/providers' do
      let!(:provider) { create(:provider) }

      it 'returns ok' do
        get '/admin/providers'
        expect(response).to have_http_status(:ok)
      end

      it 'lists providers' do
        get '/admin/providers'
        expect(response.body).to include(provider.last_name)
      end
    end

    describe 'GET /admin/providers/new' do
      it 'returns ok' do
        get '/admin/providers/new'
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /admin/providers' do
      let(:valid_params) do
        {
          provider: {
            first_name: 'Jane',
            last_name:  'Smith',
            npi:        '1234567890',
            specialty:  'Cardiology',
            clinic_name: 'General Hospital'
          }
        }
      end

      it 'creates a provider' do
        expect {
          post '/admin/providers', params: valid_params
        }.to change(Provider, :count).by(1)
      end

      it 'redirects to the new provider' do
        post '/admin/providers', params: valid_params
        expect(response).to redirect_to(admin_provider_path(Provider.last))
      end
    end

    describe 'GET /admin/providers/:id' do
      let(:provider) { create(:provider) }

      it 'returns ok' do
        get "/admin/providers/#{provider.id}"
        expect(response).to have_http_status(:ok)
      end

      it 'shows provider details' do
        get "/admin/providers/#{provider.id}"
        expect(response.body).to include(provider.first_name, provider.last_name)
      end
    end

    describe 'GET /admin/providers/:id/edit' do
      let(:provider) { create(:provider) }

      it 'returns ok' do
        get "/admin/providers/#{provider.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /admin/providers/:id' do
      let(:provider) { create(:provider) }

      it 'updates the provider and redirects' do
        patch "/admin/providers/#{provider.id}", params: { provider: { first_name: 'Updated' } }
        expect(provider.reload.first_name).to eq('Updated')
        expect(response).to redirect_to(admin_provider_path(provider))
      end
    end

    describe 'DELETE /admin/providers/:id' do
      let!(:provider) { create(:provider) }

      it 'deletes the provider' do
        expect {
          delete "/admin/providers/#{provider.id}"
        }.to change(Provider, :count).by(-1)
      end

      it 'redirects to index' do
        delete "/admin/providers/#{provider.id}"
        expect(response).to redirect_to(admin_providers_path)
      end
    end
  end
end
