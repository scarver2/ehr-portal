# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        # JWT is stateless — no CSRF token needed for these endpoints
        skip_before_action :verify_authenticity_token

        private

        # Called on successful sign-in. The JWT is emitted automatically by
        # devise-jwt in the Authorization response header.
        def respond_with(resource, _opts = {})
          render json: {
            user: {
              id: resource.id,
              email: resource.email
            }
          }, status: :ok
        end

        # Called on successful sign-out.
        def respond_to_on_destroy
          render json: { message: "Logged out successfully" }, status: :ok
        end
      end
    end
  end
end
