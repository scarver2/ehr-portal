# spec/channels/application_cable/connection_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  describe "#connect" do
    let(:user) { create(:user, :patient) }

    context "when the session contains a valid user id (Devise 5 hash format)" do
      it "identifies as current_user" do
        connect "/cable", session: { "warden.user.user.key" => { "id" => user.id, "token" => "x" } }
        expect(connection.current_user).to eq(user)
      end
    end

    context "when the session contains a valid user id (Devise < 5 array format)" do
      it "identifies as current_user" do
        connect "/cable", session: { "warden.user.user.key" => [[user.id], "salt"] }
        expect(connection.current_user).to eq(user)
      end
    end

    context "when the session has no warden key" do
      it "rejects the connection" do
        expect { connect "/cable" }.to have_rejected_connection
      end
    end

    context "when the session user id does not match any user" do
      it "rejects the connection" do
        expect {
          connect "/cable", session: { "warden.user.user.key" => { "id" => 0, "token" => "x" } }
        }.to have_rejected_connection
      end
    end
  end
end
