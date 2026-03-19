# db/migrate/20260319071215_create_insurance_verifications.rb

class CreateInsuranceVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :insurance_verifications do |t|
      t.references :user,              null: false, foreign_key: true
      t.references :insurance_profile, null: false, foreign_key: true
      t.string  :request_uuid,        null: false
      t.string  :status,              null: false, default: "pending"
      t.string  :payer_name
      t.string  :plan_name
      t.integer :copay_cents
      t.integer :deductible_cents
      t.integer :oop_max_cents
      t.jsonb   :raw_response,        null: false, default: {}
      t.string  :external_reference
      t.text    :error_message
      t.datetime :verified_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :insurance_verifications, :request_uuid, unique: true
    add_index :insurance_verifications, :status
  end
end
