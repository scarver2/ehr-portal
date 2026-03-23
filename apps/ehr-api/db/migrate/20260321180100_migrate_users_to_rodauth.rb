# frozen_string_literal: true

class MigrateUsersToRodauth < ActiveRecord::Migration[8.1]
  def up
    # Create Rodauth account for each existing User
    User.find_each do |user|
      # Skip if account already exists
      next if Account.exists?(user_id: user.id)

      Account.create!(
        user_id: user.id,
        email: user.email,
        password_hash: user.encrypted_password || BCrypt::Password.create('change_me'),
        status: 'verified',
        last_login_at: user.updated_at
      )

      # Migrate role enum to Rolify
      # Old enum values: admin, provider, staff, patient
      # New: only provider, staff, patient (admin users moved to AdminUser)
      case user.role
      when 'provider'
        user.add_role(:provider)
      when 'staff'
        user.add_role(:staff)
      when 'patient'
        user.add_role(:patient)
      when 'admin'
        # Admin users should be migrated to AdminUser model separately
        # For now, treat as staff to maintain access
        user.add_role(:staff)
        Rails.logger.warn("User #{user.id} had admin role but should be migrated to AdminUser")
      end
    end
  end

  def down
    Account.delete_all
    UserRole.delete_all
  end
end
