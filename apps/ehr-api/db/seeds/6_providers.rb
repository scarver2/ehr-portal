# apps/ehr-api/db/seeds/providers.rb
# frozen_string_literal: true

require "csv"

Rails.logger.debug "Creating seed Providers from CSV..."

# Ensure required specialties exist
specialty_names = ["Internal Medicine", "Oncology", "Immunology", "Infectious Disease", "Surgery", "Administration"]
specialty_names.each do |name|
  Specialty.find_or_create_by!(name: name)
end

csv_path = Rails.root.join("db/seeds/data/providers.csv")

unless File.exist?(csv_path)
  Rails.logger.warn "Providers CSV not found at #{csv_path}. Skipping provider seeding."
  return
end

provider_count = 0

CSV.foreach(csv_path, headers: true) do |row|
  specialty = Specialty.find_by(name: row["specialty"])
  role = row["role"] || "provider"

  provider = Provider.find_or_create_by!(npi: row["npi"]) do |p|
    p.first_name  = row["first_name"]
    p.last_name   = row["last_name"]
    p.clinic_name = row["clinic_name"]
    p.specialty   = specialty
    p.photo_url   = row["photo_url"]
  end

  # Create associated user with appropriate role if not already associated
  unless provider.user
    email = "#{row["first_name"].downcase}.#{row["last_name"].downcase}@ppth.med"
    user = User.find_or_create_by!(email: email) do |u|
      u.add_role(role.to_sym)
    end

    # Create Account for password management (Rodauth) if not already created
    Account.find_or_create_by!(user_id: user.id) do |account|
      account.email = user.email
      account.password_hash = BCrypt::Password.create("password")
      account.status = "verified"
    end

    provider.update!(user: user)
  end

  provider_count += 1
end

Rails.logger.debug { "Seeded #{provider_count} providers from CSV" }
