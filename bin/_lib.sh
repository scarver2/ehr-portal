#!/usr/bin/env bash
# bin/_lib.sh

set -euo pipefail

PROJECT_NAME="ehr-portal"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

COMMAND_NAME="$(basename "${BASH_SOURCE[1]:-$0}")"

banner() {
  echo ""
  echo "EHR Portal CLI"
  echo "Command: $COMMAND_NAME"
  echo "Root:    $ROOT_DIR"
  echo ""
}

# bash functions
check() {
  if command -v "$1" >/dev/null 2>&1; then
    success "$1 detected"
  else
    fail "$1 is not installed"
  fi
}

execute_scripts() {
  local dir="${1}"

  for script in "$dir"/[0-9][0-9]_[a-zA-Z0-9_-]*; do
    if [[ -x "$script" ]]; then
      "$script"
    else
      echo "Skipping non-executable: $(basename "$script")"
    fi
  done
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    exit 1
  fi
}

# bash prompts
info() {
  echo "→ $1"
}

success() {
  echo "✔ $1"
}

fail() {
  echo "✖ $1"
  exit 1
}
