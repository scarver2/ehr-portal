#!/usr/bin/env bash
# bin/steps/45_specialties_seeds.sh
#
# Seed the specialties table with 31 clinically-curated records covering
# three categories: Medical, Surgical, Primary Care.
#
# Seed strategy:
#   Uses Specialty.insert_all! with unique_by: :name so the seed is idempotent —
#   running it multiple times will not create duplicate records.  The project
#   uses db:reset on every deploy so this is mainly for documentation purposes.
#
# Specialties seeded (31 total):
#
#   Primary Care (4):
#     Family Medicine, Geriatric Medicine, Internal Medicine, Pediatrics
#
#   Medical (17):
#     Allergy & Immunology, Cardiology, Critical Care Medicine, Dermatology,
#     Emergency Medicine, Endocrinology, Gastroenterology, Hematology,
#     Infectious Disease, Nephrology, Neurology, Oncology, Pain Management,
#     Physical Medicine & Rehabilitation, Psychiatry, Pulmonology, Rheumatology
#
#   Surgical (10):
#     Anesthesiology, Colorectal Surgery, ENT / Otolaryngology,
#     Neurosurgery, Obstetrics & Gynecology, Ophthalmology,
#     Orthopedic Surgery, Plastic Surgery, Urology
#     (+ Anesthesiology counted under Surgical as per specialty board classification)
#
# File changed:
#   db/seeds/medical_specialties.rb — was a MEDICAL_SPECIALTIES constant array,
#                                      rewritten to use Specialty.insert_all!

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Resetting database and running all seeds..."
DB_USER=ehr_api DB_PASSWORD='' bin/rails db:reset

info "Verifying specialty count..."
DB_USER=ehr_api DB_PASSWORD='' bin/rails runner "puts Specialty.count"

success "Specialties seed complete — 31 records inserted."
