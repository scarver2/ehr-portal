# apps/ehr-api/db/seeds/providers.rb
# frozen_string_literal: true

Rails.logger.debug "Creating seed Providers with House MD cast..."

# House MD medical staff with photo URLs (primarily from public sources and official imagery)
house_md_providers = [
  {
    first_name: "Gregory",
    last_name: "House",
    specialty: "Internal Medicine",
    npi: 1_234_567_890,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/4/47/Laurie_Hugh.jpg"
  },
  {
    first_name: "James",
    last_name: "Wilson",
    specialty: "Oncology",
    npi: 1_234_567_891,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/e/e5/Robert_Sean_Leonard_2014.jpg"
  },
  {
    first_name: "Robert",
    last_name: "Chase",
    specialty: "Internal Medicine",
    npi: 1_234_567_892,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/a/a2/Jesse_Spencer_2011.jpg"
  },
  {
    first_name: "Allison",
    last_name: "Cameron",
    specialty: "Immunology",
    npi: 1_234_567_893,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/8/8e/JenniferMorrison2019.jpg"
  },
  {
    first_name: "Eric",
    last_name: "Foreman",
    specialty: "Infectious Disease",
    npi: 1_234_567_894,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/6/6f/Omar_Epps_2010.jpg"
  },
  {
    first_name: "Christopher",
    last_name: "Taub",
    specialty: "Surgery",
    npi: 1_234_567_895,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/f/f8/Peter_Jacobson_2009.jpg"
  },
  {
    first_name: "Remy",
    last_name: "Hadley",
    specialty: "Internal Medicine",
    npi: 1_234_567_896,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/1/17/Olivia_Wilde_2016.jpg"
  },
  {
    first_name: "Lisa",
    last_name: "Cuddy",
    specialty: "Administration",
    npi: 1_234_567_897,
    clinic_name: "Princeton-Plainsboro Teaching Hospital",
    photo_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/Lisa_Edelstein_2014.jpg",
    role: "administrator"
  }
]

internal_medicine = Specialty.find_by(name: "Internal Medicine")
oncology = Specialty.find_by(name: "Oncology") || Specialty.create!(name: "Oncology", description: "Cancer treatment and management")
immunology = Specialty.find_by(name: "Immunology") || Specialty.create!(name: "Immunology", description: "Immune system disorders")
infectious_disease = Specialty.find_by(name: "Infectious Disease") || Specialty.create!(name: "Infectious Disease", description: "Infection treatment")
surgery = Specialty.find_by(name: "Surgery") || Specialty.find_by(name: "General Surgery")
administration_specialty = Specialty.find_by(name: "Administration") || Specialty.create!(name: "Administration", description: "Hospital administration and management")

specialty_map = {
  "Internal Medicine" => internal_medicine,
  "Oncology" => oncology,
  "Immunology" => immunology,
  "Infectious Disease" => infectious_disease,
  "Surgery" => surgery,
  "Administration" => administration_specialty
}

Rails.logger.debug { "Seeding #{house_md_providers.length} House MD medical staff..." }

house_md_providers.each do |provider_data|
  specialty = specialty_map[provider_data[:specialty]]
  role = provider_data[:role] || "provider"

  provider = Provider.find_or_create_by!(npi: provider_data[:npi]) do |p|
    p.first_name  = provider_data[:first_name]
    p.last_name   = provider_data[:last_name]
    p.clinic_name = provider_data[:clinic_name]
    p.specialty   = specialty
    p.photo_url   = provider_data[:photo_url]
  end

  # Create associated user with appropriate role if not already associated
  unless provider.user
    email = "#{provider_data[:first_name].downcase}.#{provider_data[:last_name].downcase}@ppth.med"
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
end

Rails.logger.debug { "Seeded #{house_md_providers.length} House MD medical staff with photos" }
