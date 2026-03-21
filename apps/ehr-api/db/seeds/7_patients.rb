# apps/ehr-api/db/seeds/patients.rb
# frozen_string_literal: true

# House MD patients — actor DOBs, stable MRNs, upserted so re-seeding is safe
house_patients = [
  { first_name: "Rebecca",  last_name: "Adler",     gender: "female", condition: "Autoimmune encephalitis",    dob: "1969-06-19", mrn: "10000001" }, # Robin Tunney
  { first_name: "Amber",    last_name: "Volakis",   gender: "female", condition: "Systemic lupus erythematosus", dob: "1975-03-22", mrn: "10000002" }, # Anne Dudek
  { first_name: "Cameron",  last_name: "Palmer",    gender: "female", condition: "Basilar artery thrombosis",  dob: "1979-04-12", mrn: "10000003" }, # Jennifer Morrison
  { first_name: "Evelyn",   last_name: "Poulos",    gender: "female", condition: "Sarcoidosis",               dob: "1962-11-15", mrn: "10000004" }, # Carmen Argenziano ep
  { first_name: "Henry",    last_name: "Knight",    gender: "male",   condition: "Hemochromatosis",           dob: "1948-09-22", mrn: "10000005" }, # John Cho
  { first_name: "Jake",     last_name: "McCullough", gender: "male",  condition: "Addison's disease",         dob: "1985-07-10", mrn: "10000006" }, # Cole Evan Weiss
  { first_name: "Kris",     last_name: "Powell",    gender: "female", condition: "Chronic arsenic poisoning", dob: "1972-05-08", mrn: "10000007" }, # Cynthia Nixon
  { first_name: "Mara",     last_name: "Cowan",     gender: "female", condition: "Meningitis",               dob: "1980-02-28", mrn: "10000008" }, # Mira Sorvino
  { first_name: "Nathan",   last_name: "Paige",     gender: "male",   condition: "Neurosyphilis",            dob: "1966-04-15", mrn: "10000009" }, # David Morse
  { first_name: "Tom",      last_name: "Brock",     gender: "male",   condition: "Myxedema",                 dob: "1955-10-30", mrn: "10000010" }, # Scott Foley
]

encounter_types = %w[office_visit telehealth follow_up annual_exam]
statuses = %w[completed scheduled]

puts "Seeding #{house_patients.length} House MD patients..."

house = Provider.find_by(first_name: "Gregory", last_name: "House")
other_providers = Provider.where.not(id: house.id)

house_patients.each do |patient_data|
  stable_email = "#{patient_data[:first_name].downcase}.#{patient_data[:last_name].downcase}@ppth.med"

  user = User.find_or_create_by!(email: stable_email) do |u|
    u.role                  = :patient
    u.password              = "password"
    u.password_confirmation = "password"
  end

  patient = Patient.find_or_initialize_by(mrn: patient_data[:mrn])
  is_new  = patient.new_record?

  patient.assign_attributes(
    user:                    user,
    first_name:              patient_data[:first_name],
    last_name:               patient_data[:last_name],
    date_of_birth:           patient_data[:dob],
    gender:                  patient_data[:gender],
    phone:                   patient.phone    || Faker::PhoneNumber.phone_number,
    address:                 patient.address  || Faker::Address.full_address,
    emergency_contact_name:  patient.emergency_contact_name  || Faker::Name.name,
    emergency_contact_phone: patient.emergency_contact_phone || Faker::PhoneNumber.phone_number
  )
  patient.save!

  # Seed Dr. House encounter only once per patient
  Encounter.find_or_create_by!(
    patient:        patient,
    provider:       house,
    encounter_type: :office_visit
  ) do |e|
    e.status         = :completed
    e.encountered_at = Faker::Time.backward(days: 30)
    e.chief_complaint = patient_data[:condition]
  end

  # Random encounters — only on first seed to avoid accumulation
  next unless is_new

  other_provider_count = rand(0..10)
  other_providers.sample(other_provider_count).each do |provider|
    Encounter.create!(
      patient:         patient,
      provider:        provider,
      encounter_type:  encounter_types.sample,
      status:          statuses.sample,
      encountered_at:  Faker::Time.backward(days: 60),
      chief_complaint: "Follow-up consultation"
    )
  end
end

puts "Upserted #{house_patients.length} patients with encounters"
