# app/channels/insurance_verification_channel.rb
# frozen_string_literal: true

class InsuranceVerificationChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user.present?

    stream_for current_user
  end
end
