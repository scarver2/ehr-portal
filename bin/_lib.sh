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

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    exit 1
  fi
}

ensure_dir() {
  mkdir -p "$1"
}

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
