#!/usr/bin/env bash
# bin/functions/messaging.sh

banner() {
  [[ "${EHR_QUIET:-0}" == "1" ]] && return
  echo ""
  echo "⚕️ EHR Portal CLI"
  echo "Root:    $ROOT_DIR"
  [[ -n "${APP_DIR:-}" ]] && echo "App:     ${APP_DIR#"$ROOT_DIR/"}"
  echo "Command: $COMMAND_NAME"
  echo ""
}

info()    { echo "→ $1"; }
success() { echo "✔ $1"; }
warn()    { echo "⚠ $1"; }
fail()    { echo "✖ $1"; exit 1; }
abort()   { echo "✖ $1"; exit 1; }
