class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_honeybadger_context

  private

  # Called by ActiveAdmin's config.before_action for every admin controller action.
  # authenticate_user! already handles unauthenticated requests; this handles
  # authenticated users who lack the admin role.
  def require_admin_role
    return if current_user&.admin?
    return unless current_user # unauthenticated — let authenticate_user! handle it

    sign_out current_user
    redirect_to new_user_session_path, alert: 'Not authorized.'
  end

  def set_honeybadger_context
    return unless current_user

    Honeybadger.context(
      user_id: current_user.id,
      user_email: current_user.email
    )
  end
end
