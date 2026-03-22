# apps/ehr-api/db/seeds/medical_specialties.rb
# frozen_string_literal: true

require "csv"

Rails.logger.debug "Seeding medical specialties from CSV..."

csv_path = Rails.root.join("db/seeds/data/specialties.csv")

unless File.exist?(csv_path)
  Rails.logger.warn "Specialties CSV not found at #{csv_path}. Skipping specialty seeding."
  return
end

specialty_count = 0

CSV.foreach(csv_path, headers: true) do |row|
  Specialty.find_or_create_by!(name: row["name"]) do |s|
    s.category = row["category"]
  end
  specialty_count += 1
end

Rails.logger.debug { "  → #{specialty_count} specialties seeded from CSV." }
