# spec/requests/admin/dashboard_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Dashboard', type: :request do
  describe 'GET /admin' do
    context 'when not authenticated' do
      it 'redirects to login' do
        get '/admin'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated as admin' do
      before { sign_in create(:admin_user) }

      it 'returns ok' do
        get '/admin'
        expect(response).to have_http_status(:ok)
      end

      it 'renders the dashboard' do
        get '/admin'
        expect(response.body).to include('Dashboard')
      end
    end

    %i[provider staff patient].each do |role|
      context "when authenticated as #{role}" do

        it 'signs out and redirects to login' do
          get '/admin'
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
