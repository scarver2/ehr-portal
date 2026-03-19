# apps/ehr-api/app/models/specialty.rb
# frozen_string_literal: true

class Specialty < ApplicationRecord
  has_many :providers, dependent: :nullify, inverse_of: :specialty

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :alphabetical, -> { order(:name) }
  scope :by_category,  ->(cat) { where(category: cat) }

  def self.ransackable_attributes(auth_object = nil)
    %w[category id name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[providers]
  end
end
