# spec/requests/health_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health & root' do
  describe 'GET /' do
    it 'redirects to /admin' do
      get '/'
      expect(response).to redirect_to('/admin')
    end
  end

  describe 'GET /healthz' do
    it 'returns 200 ok' do
      get '/healthz'
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('ok')
    end
  end

  describe 'GET /up' do
    it 'returns 200 ok' do
      get '/up'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /api/up' do
    it 'returns 200 ok' do
      get '/api/up'
      expect(response).to have_http_status(:ok)
    end
  end
end
