# db/seeds/z_insurance_profiles.rb
# frozen_string_literal: true

# Assigns an insurance profile to the first 10 seeded patients.
# Runs last (z_ prefix) so payers and patients already exist.

Rails.logger.debug 'Seeding insurance profiles...'

patients = Patient.includes(:user).order(:id).to_a
payers   = Payer.active.to_a

if payers.empty?
  Rails.logger.debug '  ⚠ No active payers found — skipping insurance profiles'
  return
end

seeded = 0

patients.each_with_index do |patient, i|
  next if patient.user.insurance_profile.present?

  payer = payers[i % payers.size]

  InsuranceProfile.create!(
    member_id: "MBR#{Faker::Number.unique.number(digits: 9)}",
    payer_name: payer.name,
    payer: payer,
    status: 'pending',
    user: patient.user
  )

  seeded += 1
end

Rails.logger.debug { "Seeded #{seeded} insurance profiles (#{InsuranceProfile.count} total)" }
