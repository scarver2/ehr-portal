# apps/ehr-api/app/models/provider.rb

class Provider < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "first_name", "id", "id_value", "last_name", "updated_at"]
  end
end
