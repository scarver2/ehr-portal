# bin/steps/43_medications_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating medications seed..."

mkdir -p apps/ehr-api/db/seeds

cat << 'EOF' > apps/ehr-api/db/seeds/medications.rb
# apps/ehr-api/db/seeds/medications.rb
# frozen_string_literal: true

puts "Seeding medications..."
# TODO: Implement medications seeding
EOF
