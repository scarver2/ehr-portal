# app/workers/insurance_verification_worker.rb
# frozen_string_literal: true

class InsuranceVerificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: :insurance, retry: 10

  def perform(verification_id)
    verification = InsuranceVerification.find(verification_id)
    profile      = verification.insurance_profile
    payer        = profile.payer

    cached = RteCache.read(
      payer_code: payer&.payer_code || 'UNKNOWN',
      member_id: profile.member_id
    )

    if cached
      Rails.logger.info "RTE CACHE HIT for #{profile.member_id}"
      apply_cached_response(verification, cached)
      return
    end

    verification.with_lock do
      return unless verification.may_start_request?

      verification.start_request!
      verification.broadcast!
    end

    response = FakePayerGateway.new(verification).check_eligibility

    RteCache.write(
      payer_code: payer&.payer_code || 'UNKNOWN',
      member_id: profile.member_id,
      data: response
    )

    apply_response(verification, response)
  rescue StandardError => e
    verification&.with_lock do
      if verification.may_mark_failed?
        verification.update!(error_message: e.message)
        verification.mark_failed!
        verification.broadcast!
      end
    end
    raise
  end

  private

  def apply_response(verification, response)
    verification.with_lock do
      return unless verification.may_mark_verified?

      verification.update!(
        payer_name: response[:payer_name],
        plan_name: response[:plan_name],
        copay_cents: response[:copay_cents],
        deductible_cents: response[:deductible_cents],
        oop_max_cents: response[:oop_max_cents],
        raw_response: response,
        external_reference: response[:reference_id],
        verified_at: Time.current,
        expires_at: 24.hours.from_now
      )
      verification.mark_verified!
      verification.broadcast!
    end
  end

  def apply_cached_response(verification, response)
    verification.with_lock do
      return unless verification.may_mark_verified?

      verification.update!(
        raw_response: response,
        verified_at: Time.current
      )
      verification.mark_verified!
      verification.broadcast!
    end
  end
end
