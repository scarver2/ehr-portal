# frozen_string_literal: true

class AddPayerToInsuranceProfiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :insurance_profiles, :payer, null: false, foreign_key: true
  end
end
