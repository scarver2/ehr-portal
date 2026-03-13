#!/usr/bin/env bash
# bin/steps/02_docker.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

info "Checking prerequisites for Docker..."

check "docker"

info "Creating Docker environment..."

cat <<EOF > compose.yml
# compose.yml

services:
  postgres:
    image: postgres:18.3
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
  # redis:
  #   image: redis:8.6.1
  #   ports:
  #     - "6379:6379"
EOF

cat <<EOF > bin/up
#!/usr/bin/env bash
# bin/up

source "\$(dirname "\$0")/_lib.sh"

banner

# Default behavior: up -d
# You can override/extend by passing args, e.g.:
#   bin/up --build
#   bin/up --build --remove-orphans
#   bin/up -d --build
if [[ \$# -eq 0 ]]; then
  docker compose up -d
else
  docker compose up "\$@"
fi
EOF

cat <<EOF > bin/down
#!/usr/bin/env bash
# bin/down

source "\$(dirname "\$0")/_lib.sh"

banner

docker compose down
EOF

cat <<EOF > bin/logs
#!/usr/bin/env bash
# bin/logs
source "\$(dirname "\$0")/_lib.sh"

banner

docker compose logs
EOF

cat <<EOF > bin/restart
#!/usr/bin/env bash
# bin/restart

source "\$(dirname "\$0")/_lib.sh"

banner

"\$SCRIPT_DIR/down"

if [[ \$# -eq 0 ]]; then
  "\$SCRIPT_DIR/up"
else
  "\$SCRIPT_DIR/up" "\$@"
fi
EOF

chmod +x bin/down bin/logs bin/restart bin/up


# TODO: pull from GitHub 
# https://raw.githubusercontent.com/ronald2wing/.dockerignore/refs/heads/master/frameworks/nextjs.dockerignore
# https://raw.githubusercontent.com/ronald2wing/.dockerignore/refs/heads/master/frameworks/ruby-on-rails.dockerignore
