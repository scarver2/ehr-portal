# app/models/insurance_profile.rb
# frozen_string_literal: true

class InsuranceProfile < ApplicationRecord
  belongs_to :user
  belongs_to :payer, optional: true

  has_many :insurance_verifications, dependent: :destroy

  validates :member_id, :payer_name, presence: true

  after_create_commit :trigger_verification

  private

  def trigger_verification
    verification = user.insurance_verifications.create!(
      insurance_profile: self,
      payer_name: payer_name
    )
    verification.enqueue!
    verification.broadcast!
    InsuranceVerificationWorker.perform_async(verification.id)
  end
end
