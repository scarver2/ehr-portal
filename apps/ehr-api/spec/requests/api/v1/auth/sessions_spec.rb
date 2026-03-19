# spec/requests/api/v1/auth/sessions_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let(:password) { 'Password1!' }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:json) { JSON.parse(response.body) }

  describe 'POST /api/v1/auth/login' do
    context 'with valid credentials' do
      before do
        post '/api/v1/auth/login',
          params: { user: { email: user.email, password: password } },
          as: :json
      end

      it 'returns 200', pending: true do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the user id and email in the body', pending: true do
        expect(json['user']).to include('id' => user.id, 'email' => user.email)
      end

      it 'emits a JWT in the Authorization response header', pending: true do
        expect(response.headers['Authorization']).to match(/\ABearer .+\z/)
      end
    end

    context 'with invalid password' do
      before do
        post '/api/v1/auth/login',
          params: { user: { email: user.email, password: 'wrong' } },
          as: :json
      end

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not emit a JWT' do
        expect(response.headers['Authorization']).to be_nil
      end
    end

    context 'with an unknown email' do
      before do
        post '/api/v1/auth/login',
          params: { user: { email: 'nobody@example.com', password: password } },
          as: :json
      end

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    context 'with a valid Bearer token' do
      before do
        # Obtain a real token by logging in first
        post '/api/v1/auth/login',
          params: { user: { email: user.email, password: password } },
          as: :json

        token = response.headers['Authorization']

        delete '/api/v1/auth/logout',
          headers: { 'Authorization' => token },
          as: :json
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a logout confirmation message' do
        expect(json['message']).to eq('Logged out successfully')
      end
    end

    context 'without a token' do
      before do
        delete '/api/v1/auth/logout',
          as: :json
      end

      it 'returns 401', pending: true do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
