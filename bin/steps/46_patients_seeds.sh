# bin/steps/46_patients_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating patients seed..."

mkdir -p apps/ehr-api/db/seeds

cat << 'EOF' > apps/ehr-api/db/seeds/patients.rb
# apps/ehr-api/db/seeds/patients.rb
# frozen_string_literal: true

puts "Seeding patients..."

GENDERS = %w[Male Female]

TX_CITIES = [
  ["Allen",       "TX", "75013"],
  ["Anna",        "TX", "75409"],
  ["Austin",      "TX", "78701"],
  ["Carrollton",  "TX", "75006"],
  ["Dallas",      "TX", "75201"],
  ["Denton",      "TX", "76201"],
  ["Fort Worth",  "TX", "76101"],
  ["Frisco",      "TX", "75034"],
  ["Garland",     "TX", "75040"],
  ["Irving",      "TX", "75038"],
  ["McKinney",    "TX", "75069"],
  ["Plano",       "TX", "75023"],
  ["Richardson",  "TX", "75080"],
  ["Round Rock",  "TX", "78664"],
  ["San Antonio", "TX", "78201"],
  ["The Colony",  "TX", "75056"]
]

PATIENT_COUNT = 50

PATIENT_COUNT.times do
  city, state, zip = TX_CITIES.sample

  Patient.create!(
    first_name:    Faker::Name.first_name,
    last_name:     Faker::Name.last_name,
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 90),
    gender:        GENDERS.sample,
    mrn:           Faker::Number.number(digits: 8).to_s,
    phone:         Faker::PhoneNumber.phone_number,
    email:         Faker::Internet.email,
    address:       Faker::Address.street_address,
    city:          city,
    state:         state,
    zip:           zip
  )
end

puts "Seeded #{PATIENT_COUNT} patients"
EOF
