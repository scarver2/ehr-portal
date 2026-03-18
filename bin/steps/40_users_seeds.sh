#!/usr/bin/env bash
# bin/steps/40_users_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating role-based User seeds..."
cat << 'EOF' > apps/ehr-api/db/seeds/users.rb
# apps/ehr-api/db/seeds/users.rb
# frozen_string_literal: true

puts "Creating seed Users..."

[
  { email: "admin@example.com",    role: :admin    },
  { email: "provider@example.com", role: :provider },
  { email: "staff@example.com",    role: :staff    },
  { email: "patient@example.com",  role: :patient  }
].each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.role                  = attrs[:role]
    u.password              = "password"
    u.password_confirmation = "password"
  end
end
EOF
