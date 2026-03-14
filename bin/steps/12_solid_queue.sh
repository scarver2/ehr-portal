#!/usr/bin/env bash
# bin/steps/12_solid_queue.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Adding background job processing gems..."
bundle add solid_queue

# info "Creating Solid Queue configuration..."
# cat << 'EOF' > config/solid_queue.yml
# # config/solid_queue.yml

# :concurrency: 5
# :queues:
#   - critical
#   - default
#   - mailers
# EOF

# TODO: automate adding these lines to the respective files
echo "Add to config/application.rb"
info "config.active_job.queue_adapter = :solid_queue"

echo "Add to config/environments/production.rb"
info "config.solid_queue.start_processing = true"

bin/rails g solid_queue:install
