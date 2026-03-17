# bin/steps/44_hospitals_seeds.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating hospitals seed..."

mkdir -p apps/ehr-api/db/seeds

cat << 'EOF' > apps/ehr-api/db/seeds/hospitals.rb
# apps/ehr-api/db/seeds/hospitals.rb
# frozen_string_literal: true

puts "Seeding hospitals..."
# TODO: Implement hospitals seeding
EOF
