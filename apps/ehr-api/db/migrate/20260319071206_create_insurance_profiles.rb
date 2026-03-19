class CreateInsuranceProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :insurance_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :member_id
      t.string :payer_name
      t.string :status, default: "pending"
      t.jsonb  :raw_response, default: {}
      t.decimal :deductible
      t.decimal :oop_max
      t.decimal :copay
      t.datetime :verified_at

      t.timestamps
    end
  end
end
