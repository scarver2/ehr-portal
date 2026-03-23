# apps/ehr-api/app/models/vital.rb
# frozen_string_literal: true

class Vital < ApplicationRecord
  belongs_to :encounter, inverse_of: :vitals

  enum :vital_type, {
    blood_pressure: 'blood_pressure',
    heart_rate: 'heart_rate',
    temperature: 'temperature',
    weight: 'weight',
    height: 'height',
    oxygen_saturation: 'oxygen_saturation',
    respiratory_rate: 'respiratory_rate',
    bmi: 'bmi'
  }, validate: true

  UNITS = {
    blood_pressure: 'mmHg',
    heart_rate: 'bpm',
    temperature: '°F',
    weight: 'kg',
    height: 'cm',
    oxygen_saturation: '%',
    respiratory_rate: 'breaths/min',
    bmi: 'kg/m²'
  }.freeze

  validates :vital_type,  presence: true
  validates :value,       presence: true
  validates :observed_at, presence: true

  scope :by_type, ->(type) { where(vital_type: type) }
  scope :recent, -> { order(observed_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[encounter_id id observed_at unit value vital_type created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[encounter]
  end
end
