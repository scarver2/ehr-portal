# frozen_string_literal: true

class CreateVitals < ActiveRecord::Migration[8.1]
  def change
    create_table :vitals do |t|
      t.references :encounter, null: false, foreign_key: true
      t.string   :vital_type,  null: false
      t.string   :value,       null: false
      t.string   :unit
      t.datetime :observed_at, null: false
      t.text     :notes

      t.timestamps
    end

    add_index :vitals, %i[encounter_id vital_type]
  end
end
