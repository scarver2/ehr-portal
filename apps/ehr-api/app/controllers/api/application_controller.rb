# app/controllers/api/application_controller.rb
# frozen_string_literal: true

class Api::ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_api_user!

  private

  def authenticate_api_user!
    return if current_user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def current_user
    @current_user ||= begin
      raw_key = request.session["warden.user.user.key"]
      user_id = case raw_key
                when Array then raw_key.dig(0, 0)
                when Hash  then raw_key["id"]
                end
      user_id && User.find_by(id: user_id)
    end
  end
end
