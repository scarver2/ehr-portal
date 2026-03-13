#!/usr/bin/env bash
# bin/steps/50_seed-data.sh

source "$(dirname "$0")/../_lib.sh"

info "Seeding database..."
cd ../ehr-api

# TODO: Add seed data
touch db/seeds/icd10.rb
touch db/seeds/doctors.rb
touch db/seeds/hospitals.rb
touch db/seeds/medications.rb
touch db/seeds/patients.rb

cat << 'EOF' > db/seeds.rb
# apps/ehr-api/db/seeds.rb
# frozen_string_literal: true
Dir[Rails.root.join("db/seeds/*.rb")].each { |f| load f }
EOF


cat << 'EOF' > bin/rails data:download
# bin/rails data:download
namespace :data do
  desc "Download datasets"
  task download: :environment do
    require "open-uri"

    FileUtils.mkdir_p("data")

    url = "https://example.com/icd10.csv"
    file = Rails.root.join("data/icd10.csv")

    URI.open(url) do |remote|
      File.write(file, remote.read)
    end

    puts "Downloaded ICD10 dataset"
  end
end
EOF


bin/rails db:seed
