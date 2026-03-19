# app/models/insurance_verification.rb
# frozen_string_literal: true

class InsuranceVerification < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :insurance_profile

  validates :request_uuid, presence: true, uniqueness: true

  before_validation :ensure_request_uuid, on: :create

  aasm column: :status do
    state :pending,    initial: true
    state :queued
    state :requesting
    state :parsing
    state :verified
    state :failed
    state :expired
    state :canceled

    event :enqueue do
      transitions from: :pending, to: :queued
    end

    event :start_request do
      transitions from: :queued, to: :requesting
    end

    event :start_parsing do
      transitions from: :requesting, to: :parsing
    end

    event :mark_verified do
      transitions from: %i[parsing requesting], to: :verified
    end

    event :mark_failed do
      transitions from: %i[queued requesting parsing], to: :failed
    end

    event :mark_expired do
      transitions from: :verified, to: :expired
    end

    event :cancel do
      transitions from: %i[pending queued], to: :canceled
    end
  end

  def broadcast!
    InsuranceVerificationChannel.broadcast_to(
      user,
      {
        id:                  id,
        request_uuid:        request_uuid,
        status:              status,
        payer_name:          payer_name,
        plan_name:           plan_name,
        copay_cents:         copay_cents,
        deductible_cents:    deductible_cents,
        oop_max_cents:       oop_max_cents,
        verified_at:         verified_at,
        error_message:       error_message,
        updated_at:          updated_at
      }
    )
  end

  private

  def ensure_request_uuid
    self.request_uuid ||= SecureRandom.uuid
  end
end
