# spec/requests/api/v1/auth/sessions_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let(:user) { create(:user, :provider) }
  let(:json) { JSON.parse(response.body) }

  describe 'POST /api/v1/auth/login' do
    context 'with valid credentials' do
      before do
        post '/api/v1/auth/login',
          params: { user: { email: user.email, password: 'Password1!' } },
          as: :json
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the user data in the body' do
        expect(json['user']).to include(
          'id' => user.id,
          'email' => user.email,
          'provider_id' => user.provider&.id
        )
      end

      it 'returns a JWT token in the response body' do
        expect(json['token']).to be_a(String)
        expect(json['token']).to match(/\A[\w-]*\.[\w-]*\.[\w-]*\z/) # JWT format
      end

      it 'returns user roles in the response' do
        expect(json['user']['roles']).to include('provider')
      end

      it 'returns primary role for backward compatibility' do
        expect(json['user']['role']).to eq('provider')
      end

      it 'updates last_login_at on the account' do
        expect(user.account.reload.last_login_at).to be_within(1.second).of(Time.current)
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

      it 'returns an error message' do
        expect(json['errors']['base']).to include('Invalid email or password')
      end

      it 'does not return a token' do
        expect(json['token']).to be_nil
      end
    end

    context 'with an unknown email' do
      before do
        post '/api/v1/auth/login',
          params: { user: { email: 'nobody@example.com', password: 'Password1!' } },
          as: :json
      end

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a generic error message' do
        expect(json['errors']['base']).to include('Invalid email or password')
      end
    end

    context 'with missing email' do
      before do
        post '/api/v1/auth/login',
          params: { user: { email: '', password: 'Password1!' } },
          as: :json
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    context 'with a valid Bearer token' do
      let(:token) do
        post '/api/v1/auth/login',
          params: { user: { email: user.email, password: 'Password1!' } },
          as: :json
        JSON.parse(response.body)['token']
      end

      before do
        delete '/api/v1/auth/logout',
          headers: { 'Authorization' => "Bearer #{token}" },
          as: :json
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a logout confirmation message' do
        expect(json['message']).to eq('Logged out successfully')
      end

      it 'updates last_activity_at on the account' do
        expect(user.account.reload.last_activity_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'without a token' do
      before do
        delete '/api/v1/auth/logout',
          as: :json
      end

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        expect(json['errors']['base']).to include('Unauthorized')
      end
    end

    context 'with an invalid token' do
      before do
        delete '/api/v1/auth/logout',
          headers: { 'Authorization' => 'Bearer invalid.token.here' },
          as: :json
      end

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
