# apps/ehr-api/app/models/patient.rb
# frozen_string_literal: true

class Patient < ApplicationRecord
  belongs_to :user, optional: true
  has_many :encounters, dependent: :destroy, inverse_of: :patient

  validates :first_name, :last_name, presence: true
  validates :mrn, uniqueness: true, allow_blank: true
  validates :photo_url, format: {
    with: %r{\A(?:https?://|/images/).+\z},
    message: :photo_url_format,
    allow_blank: true
  }

  scope :search_by_name, lambda { |query|
    # Build a prefix-matching tsquery: "jan" → "jan:*", "jane smith" → "jane:* & smith:*"
    terms = query.to_s.split.map { |w| "#{w.gsub(/[^a-zA-Z0-9]/, '')}:*" }.join(' & ')
    where("searchable_name @@ to_tsquery('simple', ?)", terms)
  }
  scope :alphabetical, -> { order(:last_name, :first_name) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def age
    return nil unless date_of_birth

    now = Time.zone.today
    years_elapsed = now.year - date_of_birth.year
    years_elapsed -= 1 unless birthday_passed_this_year?(now)
    years_elapsed
  end

  private

  # Check if the patient's birthday has already occurred this calendar year.
  # Returns true if we've passed or are on the birthday month/day.
  def birthday_passed_this_year?(reference_date = Time.zone.today)
    dob = date_of_birth
    return false unless dob

    reference_date.month > dob.month ||
      (reference_date.month == dob.month && reference_date.day >= dob.day)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[address date_of_birth emergency_contact_name emergency_contact_phone
       first_name gender id last_name mrn phone created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[encounters user]
  end
end
