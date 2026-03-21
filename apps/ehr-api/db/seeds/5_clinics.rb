# apps/ehr-api/db/seeds/clinics.rb
# frozen_string_literal: true

# Clinic Names so providers belong somewhere.

Rails.logger.debug "Seeding clinics..."

CLINICS = [
  "Anna Health Clinic",
  "Collin County Family Practice",
  "DFW Internal Medicine",
  "Heritage Family Medicine",
  "Lone Star Primary Care",
  "North Dallas Medical Group",
  "Parkview Medical Associates",
  "Prairie Creek Medical",
  "Princeton-Plainsboro Teaching Hospital"
  "Red River Health",
  "Texas Regional Medical",
].freeze
