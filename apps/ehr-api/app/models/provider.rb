# apps/ehr-api/app/models/provider.rb
# frozen_string_literal: true

class Provider < ApplicationRecord
  belongs_to :user,      optional: true, inverse_of: :provider
  belongs_to :specialty, optional: true, inverse_of: :providers
  has_many   :encounters, inverse_of: :provider, dependent: :restrict_with_error

  # Validations
  validates :photo_url, format: {
    with: %r{^(https?://|/images/)},
    message: :photo_url_format,
    allow_blank: true
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def location
    [city, state].compact.join(', ')
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[city clinic_name created_at first_name id last_name npi specialty_id state updated_at zip]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[encounters specialty user]
  end
end
