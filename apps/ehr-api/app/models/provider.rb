# apps/ehr-api/app/models/provider.rb

class Provider < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["clinic_name", "created_at", "first_name", "id", "last_name", "npi", "specialty", "updated_at"]
  end
end
