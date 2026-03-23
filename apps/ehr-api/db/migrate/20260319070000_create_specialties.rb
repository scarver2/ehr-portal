# frozen_string_literal: true

class CreateSpecialties < ActiveRecord::Migration[8.1]
  def change
    create_table :specialties do |t|
      t.string :name, null: false
      t.string :category

      t.timestamps
    end

    add_index :specialties, :name, unique: true
    add_index :specialties, :category
  end
end
