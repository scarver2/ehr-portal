# apps/ehr-api/db/seeds/admin_users.rb
# frozen_string_literal: true

puts "Creating AdminUser..."
AdminUser.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password = 'password'
  u.password_confirmation = 'password'
end
