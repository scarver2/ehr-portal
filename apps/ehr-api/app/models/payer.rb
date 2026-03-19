# app/models/payer.rb
# frozen_string_literal: true

class Payer < ApplicationRecord
  has_many :insurance_profiles

  scope :active, -> { where(active: true) }

  validates :name, :payer_code, presence: true

  def simulated_latency
    (response_time_ms || 1500) / 1000.0
  end
end
