# spec/channels/insurance_verification_channel_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InsuranceVerificationChannel do
  let(:user) { create(:user, :patient) }

  describe '#subscribed' do
    context 'when the user is authenticated' do
      before { stub_connection current_user: user }

      it 'subscribes and streams for the current user' do
        subscribe
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_for(user)
      end
    end

    context 'when the user is not authenticated' do
      before { stub_connection current_user: nil }

      it 'rejects the subscription' do
        subscribe
        expect(subscription).to be_rejected
      end
    end
  end
end
