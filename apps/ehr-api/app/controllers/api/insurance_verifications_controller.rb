# app/controllers/api/insurance_verifications_controller.rb
# frozen_string_literal: true

class Api::InsuranceVerificationsController < ApplicationController
  before_action :authenticate_api_user!

  def create
    profile = current_user.insurance_profile
    verification = current_user.insurance_verifications.create!(
      insurance_profile: profile,
      payer_name:        profile.payer_name
    )
    verification.enqueue!
    verification.broadcast!
    InsuranceVerificationWorker.perform_async(verification.id)
    render json: serialize_verification(verification), status: :accepted
  end

  def show
    verification = current_user.insurance_verifications.find(params[:id])
    render json: serialize_verification(verification)
  end

  def index
    verifications = current_user.insurance_verifications.order(created_at: :desc)
    render json: verifications.map { |v| serialize_verification(v) }
  end

  private

  def authenticate_api_user!
    return if current_user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def serialize_verification(v)
    {
      id:               v.id,
      request_uuid:     v.request_uuid,
      status:           v.status,
      payer_name:       v.payer_name,
      plan_name:        v.plan_name,
      copay_cents:      v.copay_cents,
      deductible_cents: v.deductible_cents,
      oop_max_cents:    v.oop_max_cents,
      verified_at:      v.verified_at,
      expires_at:       v.expires_at,
      error_message:    v.error_message,
      updated_at:       v.updated_at
    }
  end
end
