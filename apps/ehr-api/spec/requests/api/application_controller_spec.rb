# spec/requests/api/application_controller_spec.rb
# frozen_string_literal: true

#
# Tests Api::ApplicationController's JWT authentication behaviour via the
# insurance_verifications endpoint (which inherits from it). Using request
# specs avoids the env-reset quirk of ActionController::TestCase that makes
# header setup in before-blocks unreliable in controller specs.

require 'rails_helper'

RSpec.describe 'Api::ApplicationController JWT authentication' do
  let(:user) { create(:user, :patient) }

  # ── current_user / authenticate_api_user! ─────────────────────────────────

  describe 'JWT Bearer token authentication' do
    context 'with a valid JWT Bearer token' do
      it 'grants access (200)' do
        get '/api/insurance_verifications',
            headers: auth_headers_for(user),
            as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no Authorization header is present' do
      it 'returns 401 Unauthorized' do
        get '/api/insurance_verifications', as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to eq('Unauthorized')
      end
    end

    context 'with a malformed / invalid token' do
      it 'returns 401 Unauthorized' do
        get '/api/insurance_verifications',
            headers: { 'Authorization' => 'Bearer not.a.valid.jwt' },
            as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the token references a user whose account is not verified' do
      before { user.account.update!(status: 'unverified') }

      it 'returns 401 Unauthorized' do
        get '/api/insurance_verifications',
            headers: auth_headers_for(user),
            as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
