# app/models/insurance_profile.rb
# frozen_string_literal: true

class InsuranceProfile < ApplicationRecord
  belongs_to :user
  belongs_to :payer, optional: true

  has_many :insurance_verifications, dependent: :destroy

  validates :member_id, :payer_name, presence: true
end
