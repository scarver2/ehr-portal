# frozen_string_literal: true

class AddPhotoUrlToProvidersAndPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :providers, :photo_url, :string, comment: "URL to provider's profile photo headshot"
    add_column :patients, :photo_url, :string, comment: "URL to patient's profile photo"

    # Add index for future photo-related queries
    add_index :providers, :photo_url
    add_index :patients, :photo_url
  end
end
