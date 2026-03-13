#!/usr/bin/env bash
# bin/functions/state.sh

save_state() {
  echo "$1" > "$STATE_FILE"
}

resume_state() {
  [[ -f "$STATE_FILE" ]] && cat "$STATE_FILE" || echo ""
}

clear_state() {
  rm -f "$STATE_FILE"
}
