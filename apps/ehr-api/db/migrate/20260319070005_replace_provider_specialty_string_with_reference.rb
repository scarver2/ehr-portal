# frozen_string_literal: true

class ReplaceProviderSpecialtyStringWithReference < ActiveRecord::Migration[8.1]
  def change
    add_reference :providers, :specialty, foreign_key: true, null: true
    remove_column :providers, :specialty, :string
  end
end
