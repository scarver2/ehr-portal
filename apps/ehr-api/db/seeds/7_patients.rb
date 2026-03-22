# apps/ehr-api/db/seeds/patients.rb
# frozen_string_literal: true

# House MD patients — actor DOBs, stable MRNs, upserted so re-seeding is safe
# Photo URLs from public sources (wikimedia commons, public domain, or licensed for reuse)
house_patients = [
  { first_name: "Amber",    last_name: "Volakis",   gender: "female", condition: "Systemic lupus erythematosus", dob: "1975-03-22", mrn: "10000002", actor: "Anne Dudek", photo_url: "https://upload.wikimedia.org/wikipedia/commons/8/8e/Anne_Dudek_2009.jpg" },
  { first_name: "Cameron",  last_name: "Palmer",    gender: "female", condition: "Basilar artery thrombosis", dob: "1979-04-12", mrn: "10000003", actor: "Jennifer Morrison", photo_url: "https://upload.wikimedia.org/wikipedia/commons/8/8e/JenniferMorrison2019.jpg" },
  { first_name: "Evelyn",   last_name: "Poulos",    gender: "female", condition: "Sarcoidosis",               dob: "1962-11-15", mrn: "10000004", actor: "Carmen Argenziano", photo_url: "https://upload.wikimedia.org/wikipedia/commons/1/13/Carmen_Argenziano_2013.jpg" },
  { first_name: "Henry",    last_name: "Knight",    gender: "male",   condition: "Hemochromatosis",           dob: "1948-09-22", mrn: "10000005", actor: "John Cho", photo_url: "https://upload.wikimedia.org/wikipedia/commons/d/d5/John_Cho_SDCC_2017.jpg" },
  { first_name: "Jake",     last_name: "McCullough", gender: "male",  condition: "Addison's disease",         dob: "1985-07-10", mrn: "10000006", actor: "Cole Evan Weiss", photo_url: "https://upload.wikimedia.org/wikipedia/commons/7/77/Cole_Evan_Weiss_2013.jpg" },
  { first_name: "Kris",     last_name: "Powell",    gender: "female", condition: "Chronic arsenic poisoning", dob: "1972-05-08", mrn: "10000007", actor: "Cynthia Nixon", photo_url: "https://upload.wikimedia.org/wikipedia/commons/4/47/Cynthia_Nixon_2017.jpg" },
  { first_name: "Mara",     last_name: "Cowan",     gender: "female", condition: "Meningitis",               dob: "1980-02-28", mrn: "10000008", actor: "Mira Sorvino", photo_url: "https://upload.wikimedia.org/wikipedia/commons/5/56/Mira_Sorvino_2009.jpg" },
  { first_name: "Nathan",   last_name: "Paige",     gender: "male",   condition: "Neurosyphilis",            dob: "1966-04-15", mrn: "10000009", actor: "David Morse", photo_url: "https://upload.wikimedia.org/wikipedia/commons/3/35/David_Morse_2011.jpg" },
  { first_name: "Rebecca",  last_name: "Adler",     gender: "female", condition: "Autoimmune encephalitis", dob: "1969-06-19", mrn: "10000001", actor: "Robin Tunney", photo_url: "https://upload.wikimedia.org/wikipedia/commons/9/95/Robin_Tunney_2011.jpg" },
  { first_name: "Tom",      last_name: "Brock",     gender: "male",   condition: "Myxedema", dob: "1955-10-30", mrn: "10000010", actor: "Scott Foley", photo_url: "https://upload.wikimedia.org/wikipedia/commons/0/0a/Scott_Foley_2012.jpg" }
]

encounter_types = %w[office_visit telehealth follow_up annual_exam]
statuses = %w[completed scheduled]

Rails.logger.debug { "Seeding #{house_patients.length} House MD patients..." }

house = Provider.find_by(first_name: "Gregory", last_name: "House")
other_providers = Provider.where.not(id: house.id)

house_patients.each do |patient_data|
  stable_email = "#{patient_data[:first_name].downcase}.#{patient_data[:last_name].downcase}@ppth.med"

  user = User.find_or_create_by!(email: stable_email) do |u|
    # Assign patient role via Rolify (before save)
    u.add_role(:patient)
  end

  # Create Account for password management (Rodauth) if not already created
  Account.find_or_create_by!(user_id: user.id) do |account|
    account.email = user.email
    account.password_hash = BCrypt::Password.create("password")
    account.status = "verified"
  end

  patient = Patient.find_or_initialize_by(mrn: patient_data[:mrn])
  is_new  = patient.new_record?

  patient.assign_attributes(
    address:                 patient.address || Faker::Address.full_address,
    date_of_birth:           patient_data[:dob],
    emergency_contact_name:  patient.emergency_contact_name  || Faker::Name.name,
    emergency_contact_phone: patient.emergency_contact_phone || Faker::PhoneNumber.phone_number,
    first_name:              patient_data[:first_name],
    gender:                  patient_data[:gender],
    last_name:               patient_data[:last_name],
    phone:                   patient.phone || Faker::PhoneNumber.phone_number,
    user:                    user,
    photo_url:               patient_data[:photo_url]
  )
  patient.save!

  # Seed Dr. House encounter only once per patient
  Encounter.find_or_create_by!(
    encounter_type: :office_visit,
    patient:        patient,
    provider:       house
  ) do |e|
    e.chief_complaint = patient_data[:condition]
    e.encountered_at = Faker::Time.backward(days: 30)
    e.status         = :completed
  end

  # Random encounters — only on first seed to avoid accumulation
  next unless is_new

  other_provider_count = rand(0..10)
  other_providers.sample(other_provider_count).each do |provider|
    Encounter.create!(
      chief_complaint: "Follow-up consultation",
      encounter_type:  encounter_types.sample,
      encountered_at:  Faker::Time.backward(days: 60),
      patient:         patient,
      provider:        provider,
      status:          statuses.sample
    )
  end
end

Rails.logger.debug { "Upserted #{house_patients.length} patients with encounters" }
