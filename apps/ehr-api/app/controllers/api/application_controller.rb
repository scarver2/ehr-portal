# app/controllers/api/application_controller.rb
# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    include ActionController::Cookies

    before_action :authenticate_api_user!

    private

    def authenticate_api_user!
      return if current_user

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def current_user
      @current_user ||= load_user_from_jwt_token
    end

    private

    def load_user_from_jwt_token
      token = extract_token_from_request
      return nil unless token

      begin
        secret = Rails.application.credentials.secret_key_base
        payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first
        user_id = payload["sub"]&.to_i
        user = User.find_by(id: user_id)
        user if user && user.account&.status == "verified"
      rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
      end
    end

    def extract_token_from_request
      auth_header = request.headers["Authorization"]
      auth_header&.sub(/\ABearer\s+/, "")
    end
  end
end
