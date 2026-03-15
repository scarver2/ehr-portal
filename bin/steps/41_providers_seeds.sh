# bin/steps/40_providers_seeds.sh

source "$(dirname "$0")/../_lib.sh"

cat << 'EOF' > apps/ehr-api/db/seeds/providers.rb
# apps/ehr-api/db/seeds/providers.rb
# frozen_string_literal: true

puts "Seeding providers..."

# Ensure consistent randomization when recreating the database
Faker::Config.random = Random.new(42)

25.times do
  Provider.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )
end

puts "Seeded 25 providers"
EOF
