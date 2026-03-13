#!/usr/bin/env bash
# bin/steps/00_folders.sh

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

info "Creating folders"

mkdir -p apps
mkdir -p docs

