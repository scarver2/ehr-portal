# frozen_string_literal: true

class CreatePayers < ActiveRecord::Migration[8.1]
  def change
    create_table :payers do |t|
      t.string :name
      t.string :payer_code
      t.string :clearinghouse
      t.string :api_endpoint
      t.boolean :requires_auth
      t.boolean :active
      t.integer :response_time_ms
      t.jsonb :metadata

      t.timestamps
    end

    add_index :payers, :payer_code, unique: true
    add_index :payers, :active
  end
end
