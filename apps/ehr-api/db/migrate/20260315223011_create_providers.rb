class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :providers do |t|
      t.string :first_name
      t.string :last_name
      t.string :npi
      t.string :specialty
      t.string :clinic_name

      t.timestamps
    end
  end
end
