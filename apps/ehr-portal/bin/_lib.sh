#!/usr/bin/env bash
# apps/ehr-portal/bin/_lib.sh

_APP_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$_APP_BIN_DIR/.." && pwd)"
unset _APP_BIN_DIR

# Tell root's _lib.sh to skip its auto-banner — we call it below after
# correcting COMMAND_NAME and APP_DIR.
_EHR_APP_CONTEXT=1 source "$APP_DIR/../../bin/_lib.sh"
unset _EHR_APP_CONTEXT

COMMAND_NAME="$(basename "${BASH_SOURCE[1]:-$0}")"

cd "$APP_DIR"
banner
