# bin/steps/40_administrators_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating AdminUser seed..."
cat << 'EOF' > apps/ehr-api/db/seeds/admin_users.rb
# apps/ehr-api/db/seeds/admin_users.rb
# frozen_string_literal: true

puts "Creating AdminUser..."
AdminUser.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password = 'password'
  u.password_confirmation = 'password'
end
EOF
