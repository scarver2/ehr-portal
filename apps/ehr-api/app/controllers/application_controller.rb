class ApplicationController < ActionController::Base
  before_action :set_honeybadger_context

  private

  def set_honeybadger_context
    return unless current_user

    Honeybadger.context(
      user_id: current_user.id,
      user_email: current_user.email
    )
  end
end
