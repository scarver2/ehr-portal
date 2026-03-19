# spec/channels/application_cable/connection_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  describe "#connect" do
    context "when warden has an authenticated user" do
      let(:user) { create(:user, :patient) }

      it "identifies as current_user" do
        connect "/cable", env: { "warden" => double(user: user) }
        expect(connection.current_user).to eq(user)
      end
    end

    context "when warden has no user" do
      it "rejects the connection" do
        expect {
          connect "/cable", env: { "warden" => double(user: nil) }
        }.to have_rejected_connection
      end
    end

    context "when warden is absent" do
      it "rejects the connection" do
        expect {
          connect "/cable"
        }.to have_rejected_connection
      end
    end
  end
end
