#!/usr/bin/env bash
# bin/steps/12_queue.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

info "Adding background job processing gems..."
bundle add sidekiq
bundle add oj

info "Creating Sidekiq configuration..."
cat << 'EOF' > config/sidekiq.yml
# config/sidekiq.yml

:concurrency: 5
:queues:
  - critical
  - default
  - mailers
EOF

# TODO: Add to config/application.rb:

echo "Add to config/application.rb"
info "config.active_job.queue_adapter = :sidekiq"
