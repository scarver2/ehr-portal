# spec/requests/application_controller_spec.rb
# frozen_string_literal: true

require 'rails_helper'

# ApplicationController has no routes of its own, so we exercise it through the
# GraphQL endpoint, which inherits from it and works with or without auth.
#
# We stub Honeybadger.context globally in a before block because the Honeybadger
# railtie and its Devise integration also call .context internally (with
# `controller:` and `user_scope:` keys). Stubbing first and then using
# `have_received` lets us make precise assertions only on our own call site.
RSpec.describe ApplicationController, type: :request do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:payload) { { query: '{ __typename }' }.to_json }

  before { allow(Honeybadger).to receive(:context) }

  describe '#set_honeybadger_context' do
    context 'when no user is signed in' do
      it 'does not set user context on Honeybadger' do
        post '/graphql', params: payload, headers: headers
        expect(Honeybadger).not_to have_received(:context).with(hash_including(:user_id))
      end
    end

    context 'when a user is signed in' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'sets Honeybadger context with the user id and email' do
        post '/graphql', params: payload, headers: headers
        expect(Honeybadger).to have_received(:context).with(
          user_id:    user.id,
          user_email: user.email
        )
      end
    end
  end
end
