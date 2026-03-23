# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[8.1]
  def up
    create_table :patients do |t|
      t.references :user, foreign_key: true, index: { unique: true }

      t.string :first_name,              null: false
      t.string :last_name,               null: false
      t.date   :date_of_birth
      t.string :gender
      t.string :mrn, index: { unique: true }
      t.string :phone
      t.string :address
      t.string :emergency_contact_name
      t.string :emergency_contact_phone

      t.timestamps
    end

    # Generated tsvector column for full-text name search (no extra gem needed)
    execute <<~SQL.squish
      ALTER TABLE patients
        ADD COLUMN searchable_name tsvector
        GENERATED ALWAYS AS (
          to_tsvector('simple',
            coalesce(first_name, '') || ' ' || coalesce(last_name, ''))
        ) STORED;
    SQL

    add_index :patients, :searchable_name, using: :gin
    add_index :patients, %i[last_name first_name]
  end

  def down
    drop_table :patients
  end
end
