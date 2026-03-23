# frozen_string_literal: true

class CreateDiagnoses < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnoses do |t|
      t.references :encounter, null: false, foreign_key: true
      t.string   :icd10_code,   null: false
      t.string   :description,  null: false
      t.string   :status,       null: false, default: 'active'
      t.datetime :diagnosed_at, null: false
      t.text     :notes

      t.timestamps
    end

    add_index :diagnoses, :icd10_code
    add_index :diagnoses, %i[encounter_id icd10_code]
  end
end
