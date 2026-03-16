# bin/steps/41_providers_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating providers seed..."

mkdir -p apps/ehr-api/db/seeds

cat << 'EOF' > apps/ehr-api/db/seeds/providers.rb
# apps/ehr-api/db/seeds/providers.rb
# frozen_string_literal: true

# Fake NPI Generator

# NPIs are 10 digits.

# Add helper:

# lib/seeds/npi_generator.rb

# def generate_fake_npi
#   rand(1_000_000_000..9_999_999_999)
# end


# Fake Clinic Names

# Add a clinic generator so providers belong somewhere.

# lib/seeds/clinic_names.rb

# CLINICS = [
#   "North Dallas Medical Group",
#   "Collin County Family Practice",
#   "Anna Health Clinic",
#   "Lone Star Primary Care",
#   "Texas Regional Medical",
#   "DFW Internal Medicine",
#   "Parkview Medical Associates",
#   "Red River Health",
#   "Prairie Creek Medical",
#   "Heritage Family Medicine"
# ]

# Not valid NPI check digits — but good enough for dev.


# Realistic Medical Specialties

# Create a simple constant list.

# lib/seeds/medical_specialties.rb

# MEDICAL_SPECIALTIES = [
#   "Family Medicine",
#   "Internal Medicine",
#   "Cardiology",
#   "Dermatology",
#   "Orthopedic Surgery",
#   "Pediatrics",
#   "Psychiatry",
#   "Radiology",
#   "Oncology",
#   "Neurology",
#   "Emergency Medicine",
#   "Ophthalmology",
#   "ENT",
#   "Urology",
#   "Gastroenterology"
# ]

puts "Seeding providers..."

# Ensure consistent randomization when recreating the database
Faker::Config.random = Random.new(42)

def generate_fake_npi
  rand(1_000_000_000..9_999_999_999)
end

25.times do
  Provider.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    npi: generate_fake_npi
  )
end

puts "Seeded 25 providers"
EOF
