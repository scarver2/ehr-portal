# apps/ehr-api/db/seeds/0_users.rb
# frozen_string_literal: true

Rails.logger.debug "Creating seed Users..."

# Create AdminUser (Devise session auth for ActiveAdmin)
Rails.logger.debug "Seeding admin@example.com AdminUser..."
AdminUser.find_or_create_by!(email: "admin@example.com") do |admin|
  admin.password = "password"
  admin.password_confirmation = "password"
end

# Create Portal Users (Rodauth JWT auth + Rolify roles)
[
  { email: "patient@example.com",  role: :patient  },
  { email: "provider@example.com", role: :provider },
  { email: "staff@example.com",    role: :staff    }
].each do |attrs|
  Rails.logger.debug { "Seeding #{attrs[:email]} user..." }
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    # Assign role BEFORE save (via find_or_create_by block completion)
    u.add_role(attrs[:role])
  end

  # Create Account for password management (Rodauth)
  Account.find_or_create_by!(user_id: user.id) do |account|
    account.email = user.email
    account.password_hash = BCrypt::Password.create("password")
    account.status = "verified"
  end
end

Rails.logger.debug "Done creating seed users."
