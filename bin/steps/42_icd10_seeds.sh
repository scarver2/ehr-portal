# bin/steps/42_icd10_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating ICD10 seed..."

mkdir -p apps/ehr-api/db/seeds

cat << 'EOF' > apps/ehr-api/db/seeds/icd10.rb
# apps/ehr-api/db/seeds/icd10.rb
# frozen_string_literal: true

puts "Seeding ICD10..."
# TODO: Implement ICD10 seeding
EOF
