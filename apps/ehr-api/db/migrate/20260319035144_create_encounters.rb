# frozen_string_literal: true

class CreateEncounters < ActiveRecord::Migration[8.1]
  def change
    create_table :encounters do |t|
      t.references :patient,  null: false, foreign_key: { to_table: :users }
      t.references :provider, null: false, foreign_key: true
      t.string   :encounter_type, null: false, default: 'office_visit'
      t.string   :status,         null: false, default: 'scheduled'
      t.datetime :encountered_at, null: false
      t.string   :chief_complaint
      t.text     :notes

      t.timestamps
    end

    add_index :encounters, :encountered_at
    add_index :encounters, %i[patient_id encountered_at]
  end
end
