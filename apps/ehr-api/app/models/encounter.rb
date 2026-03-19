# apps/ehr-api/app/models/encounter.rb
# frozen_string_literal: true

class Encounter < ApplicationRecord
  belongs_to :patient,  class_name: "User",     foreign_key: :patient_id, inverse_of: :encounters
  belongs_to :provider, class_name: "Provider", foreign_key: :provider_id, inverse_of: :encounters

  has_many :vitals,    dependent: :destroy, inverse_of: :encounter
  has_many :diagnoses, dependent: :destroy, inverse_of: :encounter

  enum :encounter_type, {
    office_visit:  "office_visit",
    telehealth:    "telehealth",
    emergency:     "emergency",
    follow_up:     "follow_up",
    annual_exam:   "annual_exam"
  }, validate: true

  enum :status, {
    scheduled:   "scheduled",
    in_progress: "in_progress",
    completed:   "completed",
    cancelled:   "cancelled"
  }, validate: true

  validates :encountered_at, presence: true
  validates :encounter_type, presence: true
  validates :status,         presence: true

  scope :for_patient,  ->(user)     { where(patient: user) }
  scope :for_provider, ->(provider) { where(provider: provider) }
  scope :recent,                    -> { order(encountered_at: :desc) }
  scope :completed,                 -> { where(status: "completed") }

  def self.ransackable_attributes(auth_object = nil)
    %w[chief_complaint encountered_at encounter_type id patient_id provider_id status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[patient provider vitals diagnoses]
  end
end
