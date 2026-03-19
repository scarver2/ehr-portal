# frozen_string_literal: true

class RewireEncountersPatientFkToPatients < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :encounters, column: :patient_id
    add_foreign_key    :encounters, :patients, column: :patient_id
  end
end
