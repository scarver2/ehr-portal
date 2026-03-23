# app/controllers/api/application_controller.rb
# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    include ActionController::Cookies

    before_action :authenticate_api_user!

    private

    def authenticate_api_user!
      return if current_user

      render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    def current_user
      @current_user ||= load_user_from_jwt_token
    end

    def load_user_from_jwt_token
      token = extract_token_from_request
      return nil unless token

      # Use Account's Rodauth-native token verification
      Account.find_user_from_jwt(token)
    end

    def extract_token_from_request
      auth_header = request.headers['Authorization']
      auth_header&.sub(/\ABearer\s+/, '')
    end
  end
end
