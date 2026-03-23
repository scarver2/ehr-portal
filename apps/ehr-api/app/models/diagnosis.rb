# apps/ehr-api/app/models/diagnosis.rb
# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  belongs_to :encounter, inverse_of: :diagnoses

  enum :status, {
    active: 'active',
    resolved: 'resolved',
    chronic: 'chronic',
    ruled_out: 'ruled_out'
  }, validate: true

  validates :icd10_code,   presence: true,
                           format: { with: /\A[A-Z][0-9]{2}(\.[A-Z0-9]{1,4})?\z/,
                                     message: 'must be a valid ICD-10 code (e.g. Z00.00)' }
  validates :description,  presence: true
  validates :status,       presence: true
  validates :diagnosed_at, presence: true

  scope :active,   -> { where(status: 'active') }
  scope :chronic,  -> { where(status: 'chronic') }
  scope :recent,   -> { order(diagnosed_at: :desc) }
  scope :by_code,  ->(code) { where(icd10_code: code) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[description diagnosed_at encounter_id icd10_code id status created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[encounter]
  end
end
