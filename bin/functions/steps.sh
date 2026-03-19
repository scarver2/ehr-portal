#!/usr/bin/env bash
# bin/functions/steps.sh

# _step_matches <step_number> <filter>
# filter formats:
#   ""      — match all
#   "20"    — exact match
#   "10-20" — inclusive range
#   "10+"   — from step 10 to end
_step_matches() {
  local step="$1"
  local filter="$2"
  local n=$(( 10#$step ))

  if [[ -z "$filter" ]]; then
    return 0
  elif [[ "$filter" =~ ^([0-9]{2})-([0-9]{2})$ ]]; then
    local lo=$(( 10#${BASH_REMATCH[1]} ))
    local hi=$(( 10#${BASH_REMATCH[2]} ))
    (( n >= lo && n <= hi ))
  elif [[ "$filter" =~ ^([0-9]{2})\+$ ]]; then
    local lo=$(( 10#${BASH_REMATCH[1]} ))
    (( n >= lo ))
  else
    [[ "$step" == "$filter" ]]
  fi
}

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

    _step_matches "$step" "$filter" || continue

    if [[ -n "$last_step" ]] && (( 10#$step <= 10#$last_step )); then
      info "Skipping completed step: $name"
      continue
    fi

    if [[ ! -x "$script" ]]; then
      info "Skipping non-executable: $name"
      continue
    fi

    info "Executing $name"

    if EHR_QUIET=1 "$script"; then
      save_state "$step"
      success "$name completed"
    else
      fail "$name failed"
    fi
  done

  clear_state
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
