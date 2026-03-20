# apps/ehr-api/db/seeds/patients.rb
# frozen_string_literal: true

# House MD patients with their canonical conditions
house_patients = [
  { first_name: "Rebecca", last_name: "Adler", gender: "female", condition: "Autoimmune encephalitis" },
  { first_name: "Amber", last_name: "Volakis", gender: "female", condition: "Systemic lupus erythematosus" },
  { first_name: "Cameron", last_name: "Palmer", gender: "female", condition: "Basilar artery thrombosis" },
  { first_name: "Evelyn", last_name: "Poulos", gender: "female", condition: "Sarcoidosis" },
  { first_name: "Henry", last_name: "Knight", gender: "male", condition: "Hemochromatosis" },
  { first_name: "Jake", last_name: "McCullough", gender: "male", condition: "Addison's disease" },
  { first_name: "Kris", last_name: "Powell", gender: "female", condition: "Chronic arsenic poisoning" },
  { first_name: "Mara", last_name: "Cowan", gender: "female", condition: "Meningitis" },
  { first_name: "Nathan", last_name: "Paige", gender: "male", condition: "Neurosyphilis" },
  { first_name: "Tom", last_name: "Brock", gender: "male", condition: "Myxedema" }
]

encounter_types = %w[office_visit telehealth follow_up annual_exam]
statuses = %w[completed scheduled]

puts "Seeding #{house_patients.length} House MD patients..."

house = Provider.find_by(first_name: "Gregory", last_name: "House")
other_providers = Provider.where.not(id: house.id)

house_patients.each do |patient_data|
  user = User.create!(
    email:                 Faker::Internet.unique.email(name: "#{patient_data[:first_name]} #{patient_data[:last_name]}"),
    role:                  :patient,
    password:              "password",
    password_confirmation: "password"
  )

  patient = Patient.create!(
    user:                    user,
    first_name:              patient_data[:first_name],
    last_name:               patient_data[:last_name],
    date_of_birth:           Faker::Date.birthday(min_age: 1, max_age: 90),
    gender:                  patient_data[:gender],
    mrn:                     Faker::Number.unique.number(digits: 8).to_s,
    phone:                   Faker::PhoneNumber.phone_number,
    address:                 Faker::Address.full_address,
    emergency_contact_name:  Faker::Name.name,
    emergency_contact_phone: Faker::PhoneNumber.phone_number
  )

  # Create encounter with Dr. House
  Encounter.create!(
    patient:       patient,
    provider:      house,
    encounter_type: :office_visit,
    status:        :completed,
    encountered_at: Faker::Time.backward(days: 30),
    chief_complaint: patient_data[:condition]
  )

  # Randomly associate with 0-10 other providers
  other_provider_count = rand(0..10)
  other_providers.sample(other_provider_count).each do |provider|
    Encounter.create!(
      patient:        patient,
      provider:       provider,
      encounter_type: encounter_types.sample,
      status:         statuses.sample,
      encountered_at: Faker::Time.backward(days: 60),
      chief_complaint: "Follow-up consultation"
    )
  end
end

puts "Created #{house_patients.length} patients with encounters"
