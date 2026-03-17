#!/usr/bin/env bash
# bin/steps/16_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating seed framework..."

cd apps/ehr-api

info "Adding Faker gem..."
bundle add faker

# Default Rails has seeds in a single file. I'm loading seeds from multiple files for better organization
info "Creating seed loader..."
mkdir -p db/seeds
cat << 'EOF' > db/seeds.rb
# apps/ehr-api/db/seeds.rb
# frozen_string_literal: true

Dir[Rails.root.join("db/seeds/*.rb")].sort.each { |f| load f }
EOF

# Example seeding mechanics:

# Example: Download dataset rake task
# cat << 'EOF' > bin/rails data:download
# # bin/rails data:download
# namespace :data do
#   desc "Download datasets"
#   task download: :environment do
#     require "open-uri"

#     FileUtils.mkdir_p("data")

#     url = "https://example.com/icd10.csv"
#     file = Rails.root.join("data/icd10.csv")

#     URI.open(url) do |remote|
#       File.write(file, remote.read)
#     end

#     puts "Downloaded ICD10 dataset"
#   end
# end
# EOF

# bin/rake data:download:icd10

# Example: Seed file which imports data from a CSV file
# cat << 'EOF' > db/seeds/icd10.rb
# # apps/ehr-api/db/seeds/icd10.rb
# # frozen_string_literal: true

# # Example seed file which imports data from a CSV file
# require "csv"

# CSV.foreach(Rails.root.join("data/icd10.csv"), headers: true) do |row|
#   Icd10.create!(row.to_h)
# end
# EOF

# Once seeds are established, run this to load all the data seeds into the database.
# bin/rails db:seed
