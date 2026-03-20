#!/usr/bin/env bash
# bin/steps/17_jwt.sh
# Add stateless JWT authentication to the Rails API using devise-jwt.
# Requires step 13 (Devise) to have been run first.

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Adding devise-jwt..."
bundle add devise-jwt

info "Configuring JWT dispatch and revocation routes..."
cat << 'EOF' >> config/initializers/devise.rb

# JWT configuration — appended by bin/steps/17_jwt.sh
Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.secret_key_base

    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/auth/login$}]
    ]

    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/auth/logout$}]
    ]

    jwt.expiration_time = 1.day.to_i
  end
end
EOF

info "Adding jwt_authenticatable to User model..."
# Insert after the existing devise(...) call in user.rb
sed -i '' '/devise :database_authenticatable/a\\         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null' \
  app/models/user.rb

info "Creating JSON sessions controller..."
mkdir -p app/controllers/api/v1/auth
cat << 'EOF' > app/controllers/api/v1/auth/sessions_controller.rb
# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json
        skip_before_action :verify_authenticity_token

        private

        def respond_with(resource, _opts = {})
          render json: { user: { id: resource.id, email: resource.email } }, status: :ok
        end

        def respond_to_on_destroy
          render json: { message: "Logged out successfully" }, status: :ok
        end
      end
    end
  end
end
EOF

info "Wiring JWT routes..."
# Update devise_for :users in routes.rb
cat << 'EOF' >> config/routes.rb

# JWT auth routes — appended by bin/steps/17_jwt.sh
# (replace the bare `devise_for :users` added by step 13 with this)
Rails.application.routes.draw do
  devise_for :users,
    path: 'api/v1/auth',
    path_names: { sign_in: 'login', sign_out: 'logout' },
    controllers: { sessions: 'api/v1/auth/sessions' },
    skip: %i[registrations confirmations passwords unlocks omniauth_callbacks]
end
EOF

info "Adding RBS signatures..."
mkdir -p sig/app/controllers/api/v1/auth
cat << 'EOF' > sig/app/controllers/api/v1/auth/sessions_controller.rbs
module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        private
        def respond_with: (::User resource, **untyped opts) -> void
        def respond_to_on_destroy: () -> void
      end
    end
  end
end
EOF

success "JWT authentication wired into Rails API"

# TODO: add request specs for POST /api/v1/auth/login and DELETE /api/v1/auth/logout
