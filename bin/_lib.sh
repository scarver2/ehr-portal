#!/usr/bin/env bash
# bin/_lib.sh

set -euo pipefail

PROJECT_NAME="ehr-portal"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

STATE_FILE="$ROOT_DIR/.ehr_state"

COMMAND_NAME="$(basename "${BASH_SOURCE[1]:-$0}")"

banner() {
  echo ""
  echo "EHR Portal CLI"
  echo "Command: $COMMAND_NAME"
  echo "Root:    $ROOT_DIR"
  echo ""
}

########################################
# Messaging helpers
########################################

info() { echo "→ $1"; }
success() { echo "✔ $1"; }
fail() { echo "✖ $1"; exit 1; }

########################################
# Command checks
########################################

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "Missing required command: $1"
  fi
}

check() {
  if command -v "$1" >/dev/null 2>&1; then
    success "$1 detected"
  else
    fail "$1 is not installed"
  fi
}

########################################
# Prompts
########################################

prompt() {
  read -r -p "$1 " REPLY
  [[ "$REPLY" == "y" ]]
}

select_menu() {
  local prompt="$1"
  shift
  local options=("$@")

  echo ""
  echo "$prompt"
  echo "================"

  local i=1
  for opt in "${options[@]}"; do
    echo "$i) $opt"
    ((i++))
  done

  echo ""

  read -r -p "Select option: " choice

  if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
    echo "${options[$((choice-1))]}"
  else
    fail "Invalid option"
  fi
}

########################################
# State management
########################################

save_state() {
  echo "$1" > "$STATE_FILE"
}

resume_state() {
  if [[ -f "$STATE_FILE" ]]; then
    cat "$STATE_FILE"
  else
    echo ""
  fi
}

clear_state() {
  rm -f "$STATE_FILE"
}

########################################
# Step runner
########################################

run_steps() {
  local step_dir="$1"
  local filter="${2:-}"

  [[ -d "$step_dir" ]] || fail "Steps directory not found: $step_dir"

  local last_step
  last_step=$(resume_state)

  info "Running steps in $step_dir"

  for script in "$step_dir"/[0-9][0-9]_*; do
    name="$(basename "$script")"
    step="${name%%_*}"

    # filter specific step
    if [[ -n "$filter" && "$step" != "$filter" ]]; then
      continue
    fi

    # resume logic
    if [[ -n "$last_step" ]]; then
      if (( step <= last_step )); then
        info "Skipping completed step: $name"
        continue
      fi
    fi

    if [[ ! -x "$script" ]]; then
      info "Skipping non-executable: $name"
      continue
    fi

    info "Executing $name"

    if "$script"; then
      save_state "$step"
      success "$name completed"
    else
      fail "$name failed"
    fi
  done

  clear_state
  success "All steps completed"
}

list_steps() {
  local step_dir="$1"

  [[ -d "$step_dir" ]] || fail "Steps directory not found: $step_dir"

  echo ""
  echo "Available Steps"
  echo "================"

  for script in "$step_dir"/[0-9][0-9]_*; do
    name="$(basename "$script")"
    step="${name%%_*}"

    # Extract STEP description
    desc=$(grep -m1 '^# STEP:' "$script" 2>/dev/null | sed 's/^# STEP:[[:space:]]*//')

    if [[ -z "$desc" ]]; then
      # fallback to filename
      desc="${name#*_}"
      desc="${desc%.sh}"
    fi

    printf "%s  %s\n" "$step" "$desc"
  done

  echo ""
}
