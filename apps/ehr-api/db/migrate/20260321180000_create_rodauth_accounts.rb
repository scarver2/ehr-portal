class CreateRodauthAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      # Account identification
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      # Login credentials
      t.string :email, null: false
      t.index :email, unique: true

      # Password
      t.string :password_hash, null: false

      # Account status (unverified, verified, closed)
      t.string :status, null: false, default: "unverified"

      # Email verification
      t.string :email_auth_token
      t.string :verify_login_change_key
      t.datetime :verify_login_change_deadline

      # Password reset
      t.string :reset_password_key
      t.datetime :reset_password_deadline
      t.datetime :reset_password_email_sent_at

      # Audit trail
      t.datetime :last_login_at
      t.string :last_login_ip
      t.datetime :last_activity_at
      t.string :last_activity_ip
      t.integer :failed_login_attempts, default: 0
      t.datetime :locked_until

      # Timestamps
      t.timestamps
    end
  end
end
