# apps/ehr-api/app/models/provider.rb
# frozen_string_literal: true

class Provider < ApplicationRecord
  has_many :encounters, inverse_of: :provider, dependent: :restrict_with_error

  def self.ransackable_attributes(auth_object = nil)
    %w[clinic_name created_at first_name id last_name npi specialty updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[encounters]
  end
end
