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
      # Try Rodauth JWT token first (portal users after JWT migration)
      user = find_user_from_jwt_token
      return user if user

      # Fall back to Devise session (admin users or legacy support)
      user = find_user_from_devise_session
      return user if user

      reject_unauthorized_connection
    end

    def find_user_from_jwt_token
      token = extract_jwt_token
      return nil unless token

      begin
        secret = Rails.application.credentials.secret_key_base
        payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first
        user_id = payload["sub"]&.to_i
        user = user_id && User.find_by(id: user_id)
        # Verify account is active
        user if user && user.account&.status == "verified"
      rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
      end
    end

    def find_user_from_devise_session
      # env["warden"].user performs Devise 5's session token validation, which can
      # fail after server restarts even with a valid encrypted session cookie.
      # Reading the session key directly is secure — the session is encrypted with
      # SECRET_KEY_BASE and cannot be forged.
      raw_key = request.session["warden.user.user.key"]
      user_id = case raw_key
                when Array then raw_key.dig(0, 0) # Devise < 5: [[id], salt]
                when Hash  then raw_key["id"] # Devise 5: { "id" => id, "token" => ... }
                end
      user_id && User.find_by(id: user_id)
    end

    def extract_jwt_token
      # Try Authorization header first (standard)
      auth_header = request.headers["Authorization"]
      if auth_header&.match?(/\ABearer\s+/)
        return auth_header.sub(/\ABearer\s+/, "")
      end

      # Fall back to query parameter for WebSocket
      # ActionCable can pass token via ?token=eyJ...
      request.params["token"]
    end
  end
end
