#!/usr/bin/env bash
# bin/functions/steps.sh

run_steps() {
  local step_dir="$1"
  local filter="${2:-}"

  [[ -d "$step_dir" ]] || fail "Steps directory not found: $step_dir"

  local last_step
  last_step=$(resume_state)

  info "Running steps in $step_dir"

  for script in "$step_dir"/[0-9][0-9]_*; do
    local name step
    name="$(basename "$script")"
    step="${name%%_*}"

    [[ -n "$filter" && "$step" != "$filter" ]] && continue

    if [[ -n "$last_step" ]] && (( step <= last_step )); then
      info "Skipping completed step: $name"
      continue
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
    local name step desc
    name="$(basename "$script")"
    step="${name%%_*}"
    desc="${name#*_}"; desc="${desc%.sh}"
    printf "%s  %s\n" "$step" "$desc"
  done

  echo ""
}

graph_steps() {
  local step_dir="$1"

  [[ -d "$step_dir" ]] || fail "Steps directory not found: $step_dir"

  echo ""
  echo "Step Graph"
  echo "================"

  local prev=""
  for script in "$step_dir"/[0-9][0-9]_*; do
    local name step desc
    name="$(basename "$script")"
    step="${name%%_*}"
    desc="${name#*_}"; desc="${desc%.sh}"

    if [[ -z "$prev" ]]; then
      printf "  %-4s %s\n" "$step" "$desc"
    else
      printf "   │\n  %-4s %s\n" "$step" "$desc"
    fi
    prev="$step"
  done

  echo ""
}
