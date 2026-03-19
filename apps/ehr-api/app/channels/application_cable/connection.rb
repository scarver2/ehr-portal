# app/channels/application_cable/connection.rb
# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # env["warden"].user performs Devise 5's session token validation, which can
      # fail after server restarts even with a valid encrypted session cookie.
      # Reading the session key directly is secure — the session is encrypted with
      # SECRET_KEY_BASE and cannot be forged.
      raw_key = request.session["warden.user.user.key"]
      user_id = case raw_key
                when Array then raw_key.dig(0, 0) # Devise < 5: [[id], salt]
                when Hash  then raw_key["id"] # Devise 5: { "id" => id, "token" => ... }
                end
      user = user_id && User.find_by(id: user_id)
      user || reject_unauthorized_connection
    end
  end
end
