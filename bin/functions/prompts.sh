#!/usr/bin/env bash
# bin/functions/prompts.sh

prompt() {
  read -r -p "? $1 " REPLY
  [[ "$REPLY" == "y" ]]
}

select_menu() {
  local title="$1"
  shift
  local options=("$@")

  echo ""
  echo "$title"
  echo "================"

  local i=1
  for opt in "${options[@]}"; do
    echo "$i) $opt"
    ((i++))
  done

  echo ""

  read -r -p "Select option: " choice

  if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
    echo "${options[$((choice - 1))]}"
  else
    fail "Invalid option"
  fi
}
