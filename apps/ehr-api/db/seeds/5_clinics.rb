# apps/ehr-api/db/seeds/clinics.rb
# frozen_string_literal: true

require "csv"

Rails.logger.debug "Loading clinic names from CSV..."

csv_path = Rails.root.join("db/seeds/data/clinics.csv")

if File.exist?(csv_path)
  clinics = []
  CSV.foreach(csv_path, headers: true) do |row|
    clinics << row["name"]
  end
  CLINICS = clinics.freeze
  Rails.logger.debug { "  → #{clinics.length} clinic names loaded." }
else
  Rails.logger.warn "Clinics CSV not found at #{csv_path}. Using default clinics."
  CLINICS = [
    "Princeton-Plainsboro Teaching Hospital"
  ].freeze
end
