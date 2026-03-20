# apps/ehr-api/db/seeds/providers.rb
# frozen_string_literal: true

Rails.logger.debug "Creating seed Providers..."

# Create Dr. Gregory House associated with provider@example.com user
provider_user = User.find_by(email: "provider@example.com")
internal_medicine = Specialty.find_by(name: "Internal Medicine")

Provider.find_or_create_by!(first_name: "Gregory", last_name: "House") do |p|
  p.npi         = 1234567890
  p.specialty   = internal_medicine
  p.clinic_name = "Princeton-Plainsboro Teaching Hospital"
  p.user        = provider_user
end

PROVIDER_COUNT = 25

puts "Seeding #{PROVIDER_COUNT} additional providers..."

PROVIDER_COUNT.times do
  Provider.create!(
    first_name:  Faker::Name.first_name,
    last_name:   Faker::Name.last_name,
    npi:         Faker::Number.number(digits: 10),
    specialty:   Specialty.all.sample,
    clinic_name: CLINICS.sample
  )
end
