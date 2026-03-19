# apps/ehr-api/db/seeds/patients.rb
# frozen_string_literal: true

PATIENT_COUNT = 25
GENDERS       = %w[male female other prefer_not_to_say].freeze

puts "Seeding #{PATIENT_COUNT} patients..."

PATIENT_COUNT.times do
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name

  user = User.create!(
    email:                 Faker::Internet.unique.email(name: "#{first_name} #{last_name}"),
    role:                  :patient,
    password:              "password",
    password_confirmation: "password"
  )

  Patient.create!(
    user:                    user,
    first_name:              first_name,
    last_name:               last_name,
    date_of_birth:           Faker::Date.birthday(min_age: 1, max_age: 90),
    gender:                  GENDERS.sample,
    mrn:                     Faker::Number.unique.number(digits: 8).to_s,
    phone:                   Faker::PhoneNumber.phone_number,
    address:                 Faker::Address.full_address,
    emergency_contact_name:  Faker::Name.name,
    emergency_contact_phone: Faker::PhoneNumber.phone_number
  )
end
