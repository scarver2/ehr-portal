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
      @current_user ||= request.env["warden"]&.authenticate(scope: :user)
    end
  end
end
