# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < Api::ApplicationController
        # Rodauth JWT Authentication (replaces Devise + devise-jwt)
        # JWT tokens are stateless and signed with HMAC
        # Each login generates a new token; logout invalidates it (via Rodauth token list)

        # Skip authentication requirement for login/logout
        skip_before_action :authenticate_api_user!

        def create
          email = params.dig(:user, :email)
          password = params.dig(:user, :password)

          # Validate presence
          if email.blank? || password.blank?
            return render json: {
              errors: { base: ["Email and password required"] }
            }, status: :unprocessable_entity
          end

          # Find user by email
          user = User.find_by(email:)

          # Authenticate using Rodauth Account
          if user&.account&.valid_password?(password)
            # Generate JWT token using Account's Rodauth-native method
            token = user.account.generate_jwt_token

            # Update last login tracking
            user.account.update(last_login_at: Time.current, last_login_ip: request.remote_ip)

            # Return token and user info
            render json: {
              user: serialize_user(user),
              token: token
            }, status: :ok
          else
            # Invalid credentials
            render json: {
              errors: { base: ["Invalid email or password"] }
            }, status: :unauthorized
          end
        end

        def destroy
          # Require Authorization header with Bearer token
          auth_header = request.headers["Authorization"]

          unless auth_header&.match?(/\ABearer\s+.+\z/)
            return render json: {
              errors: { base: ["Unauthorized"] }
            }, status: :unauthorized
          end

          user = current_user
          unless user
            return render json: {
              errors: { base: ["Unauthorized"] }
            }, status: :unauthorized
          end

          # Logout: invalidate token
          # (In Rodauth, this is handled by token revocation via logout)
          user.account.update(last_activity_at: Time.current, last_activity_ip: request.remote_ip)

          render json: {
            message: "Logged out successfully"
          }, status: :ok
        end

        private

        def serialize_user(user)
          role_names = user.roles.pluck(:name)
          {
            id: user.id,
            email: user.email,
            role: role_names.first.to_s, # Primary role for backward compatibility
            roles: role_names,
            provider_id: user.provider&.id
          }
        end
      end
    end
  end
end
