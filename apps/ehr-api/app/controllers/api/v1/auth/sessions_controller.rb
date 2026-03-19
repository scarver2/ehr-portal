# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        # Rails automatically skips CSRF for non-HTML formats,
        # but Devise's session controller might override that.
        protect_from_forgery with: :null_session

        before_action :configure_sign_in_params, only: :create

        # Override the create action to manually authenticate and sign in,
        # bypassing Devise's warden.authenticate! which fails for JSON requests.
        # Devise's response handling (including devise-jwt) still applies.
        def create
          email = params.dig(:user, :email)
          password = params.dig(:user, :password)

          if email.blank? || password.blank?
            @user = nil
            return render json: { errors: { base: ["Email and password required"] } }, status: :unprocessable_entity
          end

          user = User.find_by(email:)

          if user&.valid_password?(password)
            # Store in @user and call sign_in to authenticate.
            # Devise will use its standard response handling via respond_with.
            @user = user
            sign_in(user, store: false)
            respond_with user
          else
            @user = nil
            render json: { errors: { base: ["Invalid email or password"] } }, status: :unauthorized
          end
        end

        # Called by respond_with on successful sign-in.
        # devise-jwt will automatically add the JWT to the Authorization response header.
        def respond_with(resource, _opts = {})
          render json: {
            user: {
              id: resource.id,
              email: resource.email,
              role: resource.role,
              provider_id: resource.provider&.id
            }
          }, status: :ok
        end

        def destroy
          # For JWT logout, require an Authorization header with a Bearer token.
          # This ensures logout only works for JWT-authenticated requests, not session-based.
          auth_header = request.headers["Authorization"]

          # Check if Authorization header is present and is a Bearer token
          if auth_header&.match?(/\ABearer\s+.+\z/)
            # Valid Bearer token present, attempt logout
            user = current_user
            if user
              sign_out(user)
              respond_to_on_destroy(user)
            else
              # Authorization header present but no authenticated user
              render json: { errors: { base: ["Unauthorized"] } }, status: :unauthorized
            end
          else
            # No Authorization header or invalid format
            render json: { errors: { base: ["Unauthorized"] } }, status: :unauthorized
          end
        end

        # Called by respond_with on successful sign-out.
        def respond_to_on_destroy(resource)
          render json: { message: "Logged out successfully" }, status: :ok
        end

        private

        def configure_sign_in_params
          devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
        end
      end
    end
  end
end
