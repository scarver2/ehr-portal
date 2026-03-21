# apps/ehr-api/db/seeds/users.rb
# frozen_string_literal: true

Rails.logger.debug "Creating seed Users..."

[
  { email: "admin@example.com",    role: :admin    },
  { email: "patient@example.com",  role: :patient  },
  { email: "provider@example.com", role: :provider },
  { email: "staff@example.com",    role: :staff    }
].each do |attrs|
  Rails.logger.debug { "Seeding #{attrs[:email]} user..." }
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.password              = "password"
    u.password_confirmation = "password"
    u.role                  = attrs[:role]
  end
end
