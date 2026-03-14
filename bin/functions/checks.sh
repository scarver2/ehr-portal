#!/usr/bin/env bash
# bin/functions/checks.sh

check() {
  if command -v "$1" >/dev/null 2>&1; then
    success "$1 detected"
  else
    fail "$1 is not installed"
  fi
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "Missing required command: $1"
  fi
}
