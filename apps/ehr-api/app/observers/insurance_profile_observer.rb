# app/observers/insurance_profile_observer.rb
# frozen_string_literal: true

class InsuranceProfileObserver < ActiveRecord::Observer
  def after_create(profile)
    verification = profile.user.insurance_verifications.create!(
      insurance_profile: profile,
      payer_name:        profile.payer_name
    )
    verification.enqueue!
    verification.broadcast!
    InsuranceVerificationWorker.perform_async(verification.id)
  end
end
