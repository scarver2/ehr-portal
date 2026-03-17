# spec/requests/admin/dashboard_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Dashboard', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /admin' do
    context 'when not authenticated' do
      it 'redirects to login' do
        get '/admin'
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    context 'when authenticated' do
      before { sign_in admin_user }

      it 'returns ok' do
        get '/admin'
        expect(response).to have_http_status(:ok)
      end

      it 'renders the dashboard' do
        get '/admin'
        expect(response.body).to include('Dashboard')
      end
    end
  end
end
