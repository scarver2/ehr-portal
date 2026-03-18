# spec/requests/graphiql_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphiQL route', type: :request do
  describe 'GET /graphiql' do
    it 'is not routable in the test environment (production guard)' do
      expect { get '/graphiql' }.to raise_error(ActionController::RoutingError)
    end
  end
end
