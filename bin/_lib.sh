#!/usr/bin/env bash
# bin/_lib.sh

set -euo pipefail
shopt -s nullglob

PROJECT_NAME="ehr-portal"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$ROOT_DIR/.ehr_state"
RUBY_VERSION="3.4.8"

COMMAND_NAME="$(basename "${BASH_SOURCE[1]:-$0}")"

for _f in "$SCRIPT_DIR/functions/"*.sh; do
  source "$_f"
done
unset _f
