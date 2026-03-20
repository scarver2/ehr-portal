# app/models/payer.rb
# frozen_string_literal: true

class Payer < ApplicationRecord
  has_many :insurance_profiles

  scope :active, -> { where(active: true) }

  validates :name, :payer_code, presence: true
end
