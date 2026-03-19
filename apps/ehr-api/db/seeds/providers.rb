# apps/ehr-api/db/seeds/providers.rb
# frozen_string_literal: true


PROVIDER_COUNT = 25

puts "Seeding #{PROVIDER_COUNT} providers..."

PROVIDER_COUNT.times do
  Provider.create!(
    first_name:  Faker::Name.first_name,
    last_name:   Faker::Name.last_name,
    npi:         Faker::Number.number(digits: 10),
    specialty:   Specialty.all.sample,
    clinic_name: CLINICS.sample
  )
end
