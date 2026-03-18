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

# outdated_command <formula>
# Checks whether a Homebrew formula (or fallback binary) is up to date.
# Prints installed vs latest and a status line. Does not exit on mismatch.
outdated_command() {
  local formula="$1"
  local brew_info="" installed="" latest=""

  brew_info="$(brew info "$formula" 2>/dev/null)" \
    || abort "Unknown Homebrew formula: $formula"

  latest="$(grep -Eo 'stable [0-9][^ ,]+' <<< "$brew_info" | head -1 | awk '{print $2}')"
  [[ -z "$latest" ]] && abort "Could not determine latest version of $formula from Homebrew"

  if brew list --formula "$formula" &>/dev/null; then
    installed="$(brew list --versions "$formula" | awk '{print $NF}')"
  fi

  if [[ -z "$installed" ]] && command -v "$formula" >/dev/null 2>&1; then
    installed="$("$formula" --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    [[ -z "$installed" ]] && \
      installed="$("$formula" -v 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  fi

  [[ -z "$installed" ]] && abort "$formula is not installed — run \`bin/setup\` to install"

  echo "$formula"
  echo "Installed : $installed"
  echo "Latest    : $latest"
  echo

  if [[ "$installed" == "$latest" ]]; then
    success "$formula is up to date"
  elif [[ "$(printf '%s\n%s\n' "$installed" "$latest" | sort -V | tail -1)" == "$latest" ]]; then
    info "$formula $latest is available — run \`bin/update\` to upgrade"
  else
    success "$formula $installed is newer than latest stable ($latest)"
  fi
}
