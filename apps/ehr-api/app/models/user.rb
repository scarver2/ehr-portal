# apps/ehr-api/app/models/user.rb
# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    admin: "admin",
    provider: "provider",
    staff: "staff",
    patient: "patient"
  }, validate: true

  validates :role, presence: true

  has_one :patient,           dependent: :destroy, inverse_of: :user
  has_one :provider,          dependent: :nullify,  inverse_of: :user
  has_one :insurance_profile, dependent: :destroy

  has_many :insurance_verifications, dependent: :destroy

  scope :provider_accounts, -> { where(role: :provider).order(:email) }
end
