# frozen_string_literal: true

class AddUserIdAndAddressToProviders < ActiveRecord::Migration[8.1]
  def change
    add_reference :providers, :user, foreign_key: true, index: { unique: true }

    add_column :providers, :city,  :string
    add_column :providers, :state, :string
    add_column :providers, :zip,   :string
  end
end
