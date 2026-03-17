# bin/steps/41_providers_seeds.sh

source "$(dirname "$0")/../_lib.sh"

mkdir -p apps/ehr-api/db/seeds

info "Creating clinics seed..."
cat << 'EOF' > apps/ehr-api/db/seeds/clinics.rb
# apps/ehr-api/db/seeds/clinics.rb
# frozen_string_literal: true

# Fake Clinic Names so providers belong somewhere.

puts "Seeding clinics..."

CLINICS = [
  "Anna Health Clinic",
  "Collin County Family Practice",
  "DFW Internal Medicine",
  "Heritage Family Medicine",
  "Lone Star Primary Care",
  "North Dallas Medical Group",
  "Parkview Medical Associates",
  "Prairie Creek Medical",
  "Red River Health",
  "Texas Regional Medical"
]
EOF

info "Creating medical specialties seed..."
cat << 'EOF' > apps/ehr-api/db/seeds/medical_specialties.rb
# apps/ehr-api/db/seeds/medical_specialties.rb
# frozen_string_literal: true

# Fake, but realistic Medical Specialties

puts "Seeding medical specialties..."

MEDICAL_SPECIALTIES = [
  "Cardiology",
  "Dermatology",
  "Emergency Medicine",
  "ENT",
  "Family Medicine",
  "Gastroenterology",
  "Internal Medicine",
  "Neurology",
  "Oncology",
  "Ophthalmology",
  "Orthopedic Surgery",
  "Pediatrics",
  "Psychiatry",
  "Radiology",
  "Urology"
]
EOF

info "Creating providers seed..."
cat << 'EOF' > apps/ehr-api/db/seeds/providers.rb
# apps/ehr-api/db/seeds/providers.rb
# frozen_string_literal: true

puts "Seeding providers..."

PROVIDER_COUNT = 25

PROVIDER_COUNT.times do
  Provider.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    npi: Faker::Number.number(digits: 10),
    specialty: MEDICAL_SPECIALTIES.sample,
    clinic_name: CLINICS.sample
  )
end

puts "Seeded #{PROVIDER_COUNT} providers"
EOF
