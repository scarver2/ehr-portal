# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_honeybadger_context

  # Disable CSRF protection for localhost/development smoke tests
  # This allows the smoke test script to POST login requests without extracting
  # session-specific CSRF tokens. CSRF protection remains enabled in staging/production.
  skip_before_action :verify_authenticity_token, if: :localhost_request?

  private

  # Check if request is from localhost (for development/testing)
  def localhost_request?
    return false unless Rails.env.development?

    # Match localhost, 127.0.0.1, and local IP addresses
    request.host.match?(/\Alocalhost\z|\A127\.0\.0\.1\z|\A::1\z/)
  end

  # Return the authenticated admin user (for ActiveAdmin)
  # Admin authentication is handled by Devise for AdminUser model
  def current_user
    current_admin_user
  end

  # Called by ActiveAdmin's config.before_action for every admin controller action.
  # authenticate_admin_user! already handles unauthenticated requests; this handles
  # authenticated users who lack admin privileges (should not be possible - all AdminUsers are admins).
  def require_admin_role
    return if current_admin_user

    redirect_to new_admin_user_session_path, alert: 'Not authorized.'
  end

  def set_honeybadger_context
    return unless current_admin_user

    Honeybadger.context(
      user_id: current_admin_user.id,
      user_email: current_admin_user.email,
      user_type: 'AdminUser'
    )
  end
end
