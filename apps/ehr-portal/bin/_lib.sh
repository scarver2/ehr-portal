#!/usr/bin/env bash
# apps/ehr-portal/bin/_lib.sh

_APP_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$_APP_BIN_DIR/.." && pwd)"
unset _APP_BIN_DIR

source "$APP_DIR/../../bin/_lib.sh"

# Root's _lib.sh sets COMMAND_NAME from BASH_SOURCE[1], which resolves to this
# file when scripts source us. Re-resolve to the actual calling script.
COMMAND_NAME="$(basename "${BASH_SOURCE[1]:-$0}")"

cd "$APP_DIR"
