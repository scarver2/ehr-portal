# apps/ehr-api/app/models/user.rb
# frozen_string_literal: true

class User < ApplicationRecord
  # Rodauth JWT authentication (replaces Devise + devise-jwt)
  # JWT tokens are stateless and signed with HMAC
  # Each User has an associated Rodauth account for password management and token validation

  # Role-based access control using Rolify
  # Supported roles: :provider, :staff, :patient (admins use separate AdminUser model)
  rolify

  # Validate email presence (Rodauth manages password via account table)
  validates :email, presence: true, uniqueness: true
  validate :has_at_least_one_role

  has_one :patient,           dependent: :destroy, inverse_of: :user
  has_one :provider,          dependent: :nullify,  inverse_of: :user
  has_one :insurance_profile, dependent: :destroy

  has_many :insurance_verifications, dependent: :destroy

  scope :provider_accounts, -> { where(roles: { name: :provider }).joins(:roles) }

  private

  def has_at_least_one_role
    errors.add(:roles, "User must have at least one role") if roles.empty?
  end
end
