# spec/requests/admin/admin_users_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::AdminUsers', type: :request do
  let(:admin_user) { create(:admin_user) }

  context 'when not authenticated' do
    it 'redirects to login' do
      get '/admin/admin_users'
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when authenticated' do
    before { sign_in admin_user }

    describe 'GET /admin/admin_users' do
      let!(:admin_user) { create(:admin_user) }

      it 'returns ok' do
        get '/admin/admin_users'
        expect(response).to have_http_status(:ok)
      end

      it 'lists admin users' do
        get '/admin/admin_users'
        expect(response.body).to include(admin_user.email)
      end
    end

    describe 'GET /admin/admin_users/new' do
      it 'returns ok' do
        get '/admin/admin_users/new'
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /admin/admin_users' do
      let(:valid_params) do
        {
          admin_user: {
            email:      'test@example.com',
            password:   'password'
          }
        }
      end

      it 'creates a admin user' do
        expect {
          post '/admin/admin_users', params: valid_params
        }.to change(AdminUser, :count).by(1)
      end

      it 'redirects to the new admin user' do
        post '/admin/admin_users', params: valid_params
        expect(response).to redirect_to(admin_admin_user_path(AdminUser.last))
      end
    end

    describe 'GET /admin/admin_users/:id' do
      let(:admin_user) { create(:admin_user) }

      it 'returns ok' do
        get "/admin/admin_users/#{admin_user.id}"
        expect(response).to have_http_status(:ok)
      end

      it 'shows admin user details' do
        get "/admin/admin_users/#{admin_user.id}"
        expect(response.body).to include(admin_user.email)
      end
    end

    describe 'GET /admin/admin_users/:id/edit' do
      let(:admin_user) { create(:admin_user) }

      it 'returns ok' do
        get "/admin/admin_users/#{admin_user.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /admin/admin_users/:id' do
      let(:admin_user) { create(:admin_user) }

      it 'updates the admin user and redirects' do
        patch "/admin/admin_users/#{admin_user.id}", params: { admin_user: { email: 'updated@example.com' } }
        expect(admin_user.reload.email).to eq('updated@example.com')
        expect(response).to redirect_to(admin_admin_user_path(admin_user))
      end
    end

    describe 'DELETE /admin/admin_users/:id' do
      let!(:admin_user) { create(:admin_user) }

      it 'deletes the admin user' do
        expect {
          delete "/admin/admin_users/#{admin_user.id}"
        }.to change(AdminUser, :count).by(-1)
      end

      it 'redirects to index' do
        delete "/admin/admin_users/#{admin_user.id}"
        expect(response).to redirect_to(admin_admin_users_path)
      end
    end
  end
end
