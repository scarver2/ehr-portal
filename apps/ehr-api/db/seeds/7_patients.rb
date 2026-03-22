# apps/ehr-api/db/seeds/patients.rb
# frozen_string_literal: true

require "csv"

Rails.logger.debug "Creating seed Patients from CSV..."

csv_path = Rails.root.join("db/seeds/data/patients.csv")

unless File.exist?(csv_path)
  Rails.logger.warn "Patients CSV not found at #{csv_path}. Skipping patient seeding."
  return
end

encounter_types = %w[office_visit telehealth follow_up annual_exam]
statuses = %w[completed scheduled]

patient_count = 0
house = Provider.find_by(first_name: "Gregory", last_name: "House")
other_providers = Provider.where.not(id: house&.id) if house

CSV.foreach(csv_path, headers: true) do |row|
  stable_email = "#{row["first_name"].downcase}.#{row["last_name"].downcase}@ppth.med"

  user = User.find_or_create_by!(email: stable_email) do |u|
    u.add_role(:patient)
  end

  # Create Account for password management (Rodauth) if not already created
  Account.find_or_create_by!(user_id: user.id) do |account|
    account.email = user.email
    account.password_hash = BCrypt::Password.create("password")
    account.status = "verified"
  end

  patient = Patient.find_or_initialize_by(mrn: row["mrn"])
  is_new = patient.new_record?

  patient.assign_attributes(
    address:                 patient.address || Faker::Address.full_address,
    date_of_birth:           row["dob"],
    emergency_contact_name:  patient.emergency_contact_name  || Faker::Name.name,
    emergency_contact_phone: patient.emergency_contact_phone || Faker::PhoneNumber.phone_number,
    first_name:              row["first_name"],
    gender:                  row["gender"],
    last_name:               row["last_name"],
    phone:                   patient.phone || Faker::PhoneNumber.phone_number,
    user:                    user,
    photo_url:               row["photo_url"]
  )
  patient.save!

  # Seed Dr. House encounter only once per patient
  if house
    Encounter.find_or_create_by!(
      encounter_type: :office_visit,
      patient:        patient,
      provider:       house
    ) do |e|
      e.chief_complaint = row["condition"]
      e.encountered_at = Faker::Time.backward(days: 30)
      e.status         = :completed
    end
  end

  # Random encounters — only on first seed to avoid accumulation
  next unless is_new && other_providers

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

  patient_count += 1
end

Rails.logger.debug { "Seeded #{patient_count} patients from CSV with encounters" }
