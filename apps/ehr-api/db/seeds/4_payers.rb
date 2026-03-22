# db/seeds/payers.rb
# frozen_string_literal: true

require "csv"

Rails.logger.debug "Seeding payers from CSV..."

csv_path = Rails.root.join("db/seeds/data/payers.csv")

unless File.exist?(csv_path)
  Rails.logger.warn "Payers CSV not found at #{csv_path}. Skipping payer seeding."
  return
end

payer_count = 0

CSV.foreach(csv_path, headers: true) do |row|
  Payer.find_or_create_by!(payer_code: row["payer_code"]) do |payer|
    payer.name             = row["name"]
    payer.clearinghouse    = row["clearinghouse"]
    payer.api_endpoint     = row["api_endpoint"]
    payer.requires_auth    = row["requires_auth"].downcase == "true"
    payer.response_time_ms = row["response_time_ms"].to_i
    payer.active           = true
  end
  payer_count += 1
end

Rails.logger.debug { "Seeded #{payer_count} payers from CSV" }
