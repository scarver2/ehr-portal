#!/usr/bin/env bash
# bin/functions/messaging.sh

banner() {
  echo ""
  echo "EHR Portal CLI"
  echo "Command: $COMMAND_NAME"
  echo "Root:    $ROOT_DIR"
  echo ""
}

info()    { echo "→ $1"; }
success() { echo "✔ $1"; }
fail()    { echo "✖ $1"; exit 1; }
