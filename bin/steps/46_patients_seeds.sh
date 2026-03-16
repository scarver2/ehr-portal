# bin/steps/46_patients_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating patients seed..."

mkdir -p apps/ehr-api/db/seeds

cat << 'EOF' > apps/ehr-api/db/seeds/patients.rb
# apps/ehr-api/db/seeds/patients.rb
# frozen_string_literal: true

puts "Seeding patients..."
# TODO: Implement patients seeding
EOF
