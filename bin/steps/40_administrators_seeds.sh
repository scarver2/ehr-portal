# bin/steps/40_administrators_seeds.sh

# Add AdminUser to seeds
cat << 'EOF' > apps/ehr-api/db/seeds/admin_users.rb
# apps/ehr-api/db/seeds/admin_users.rb
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
EOF
