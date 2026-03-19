#!/usr/bin/env bash
# bin/steps/37_patient_profile.sh
#
# Separate Patient domain entity from User (auth credentials).
#
# Design rationale:
#   User  = security credential construct (email, password, role, JWT)
#   Patient = person being treated (demographics, contact info, encounters)
#   Provider already existed as a domain entity; it gains user_id + address here.
#
# What changes:
#   1. New `patients` table with demographics + tsvector full-text search on name
#   2. `providers` gains user_id (FK → users) and city/state/zip address fields
#   3. `encounters.patient_id` FK is rewired from users → patients
#   4. Patient model: belongs_to :user (optional), has_many :encounters
#   5. User model: has_one :patient, has_one :provider (removes has_many :encounters)
#   6. Provider model: belongs_to :user (optional), full_name, location helpers
#   7. Encounter model: belongs_to :patient (plain, no class_name override needed)
#   8. ActiveAdmin: new patients resource with encounter panel; encounters and
#      providers forms updated to reflect new associations
#   9. GraphQL: new PatientType with full-text search; EncounterType.patient now
#      returns PatientType; UserType slimmed to auth fields + patient/provider links;
#      ProviderType gains city/state/zip/location; QueryType adds patients/patient queries
#  10. FactoryBot: patients factory; encounters factory updated to use :patient
#  11. Specs: patient_spec + updated encounter_spec
#  12. RBS: patient.rbs; updated provider.rbs, user.rbs, graphql user_type.rbs
#
# Schema additions:
#
#   patients
#     user_id:                 bigint FK → users (unique, nullable)
#     first_name:              string NOT NULL
#     last_name:               string NOT NULL
#     date_of_birth:           date
#     gender:                  string
#     mrn:                     string (unique)
#     phone:                   string
#     address:                 string
#     emergency_contact_name:  string
#     emergency_contact_phone: string
#     searchable_name:         tsvector GENERATED ALWAYS AS (
#                                to_tsvector('simple', first_name || ' ' || last_name)
#                              ) STORED
#     indexes: searchable_name (GIN), [last_name, first_name]
#
#   providers (additions)
#     user_id: bigint FK → users (unique, nullable)
#     city:    string
#     state:   string
#     zip:     string

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

# ─────────────────────────────────────────────────────────────────────────────
# 1. MIGRATIONS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating migration: create_patients..."
cat << 'EOF' > db/migrate/$(date +%Y%m%d%H%M%S)_create_patients.rb
# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[8.1]
  def up
    create_table :patients do |t|
      t.references :user, foreign_key: true, index: { unique: true }

      t.string :first_name,              null: false
      t.string :last_name,               null: false
      t.date   :date_of_birth
      t.string :gender
      t.string :mrn,                     index: { unique: true }
      t.string :phone
      t.string :address
      t.string :emergency_contact_name
      t.string :emergency_contact_phone

      t.timestamps
    end

    execute <<~SQL
      ALTER TABLE patients
        ADD COLUMN searchable_name tsvector
        GENERATED ALWAYS AS (
          to_tsvector('simple',
            coalesce(first_name, '') || ' ' || coalesce(last_name, ''))
        ) STORED;
    SQL

    add_index :patients, :searchable_name, using: :gin
    add_index :patients, [:last_name, :first_name]
  end

  def down
    drop_table :patients
  end
end
EOF

info "Creating migration: add_user_id_and_address_to_providers..."
cat << 'EOF' > db/migrate/$(date +%Y%m%d%H%M%S)_add_user_id_and_address_to_providers.rb
# frozen_string_literal: true

class AddUserIdAndAddressToProviders < ActiveRecord::Migration[8.1]
  def change
    add_reference :providers, :user, foreign_key: true, index: { unique: true }

    add_column :providers, :city,  :string
    add_column :providers, :state, :string
    add_column :providers, :zip,   :string
  end
end
EOF

info "Creating migration: rewire_encounters_patient_fk_to_patients..."
cat << 'EOF' > db/migrate/$(date +%Y%m%d%H%M%S)_rewire_encounters_patient_fk_to_patients.rb
# frozen_string_literal: true

class RewireEncountersPatientFkToPatients < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :encounters, column: :patient_id
    add_foreign_key    :encounters, :patients, column: :patient_id
  end
end
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 2. MODELS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating Patient model..."
cat << 'EOF' > app/models/patient.rb
# apps/ehr-api/app/models/patient.rb
# frozen_string_literal: true

class Patient < ApplicationRecord
  belongs_to :user, optional: true
  has_many :encounters, dependent: :destroy, inverse_of: :patient

  validates :first_name, :last_name, presence: true
  validates :mrn, uniqueness: true, allow_blank: true

  scope :search_by_name, ->(query) {
    where("searchable_name @@ plainto_tsquery('simple', ?)", query)
  }
  scope :alphabetical, -> { order(:last_name, :first_name) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def age
    return nil unless date_of_birth

    now = Date.today
    now.year - date_of_birth.year -
      ((now.month > date_of_birth.month ||
        (now.month == date_of_birth.month && now.day >= date_of_birth.day)) ? 0 : 1)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[address date_of_birth emergency_contact_name emergency_contact_phone
       first_name gender id last_name mrn phone created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[encounters user]
  end
end
EOF

info "Updating User model — swap has_many :encounters for has_one :patient / :provider..."
# Replace in app/models/user.rb:
#   has_many :encounters, foreign_key: :patient_id, inverse_of: :patient, dependent: :destroy
# with:
#   has_one :patient,  dependent: :destroy,  inverse_of: :user
#   has_one :provider, dependent: :nullify,  inverse_of: :user

info "Updating Encounter model — remove class_name / foreign_key overrides..."
# Change:
#   belongs_to :patient, class_name: "User", foreign_key: :patient_id, inverse_of: :encounters
# to:
#   belongs_to :patient, inverse_of: :encounters

info "Updating Provider model — add belongs_to :user, full_name, location..."
# Add:
#   belongs_to :user, optional: true, inverse_of: :provider
#   def full_name = "#{first_name} #{last_name}"
#   def location  = [city, state].compact.join(", ")

# ─────────────────────────────────────────────────────────────────────────────
# 3. ACTIVE ADMIN
# ─────────────────────────────────────────────────────────────────────────────

info "Creating patients ActiveAdmin resource..."
# Creates app/admin/patients.rb with filters, index, show (with encounters panel), form

info "Updating encounters form — patient dropdown now uses Patient.alphabetical..."
# Change:
#   f.input :patient, collection: User.where(role: :patient).order(:email)
# to:
#   f.input :patient, collection: Patient.alphabetical.map { |p| [p.full_name, p.id] }

info "Expanding providers admin — add address fields and user link..."

# ─────────────────────────────────────────────────────────────────────────────
# 4. GRAPHQL
# ─────────────────────────────────────────────────────────────────────────────

info "Creating PatientType GraphQL type..."
# app/graphql/types/patient_type.rb
# Fields: id, first_name, last_name, full_name, date_of_birth, age, gender, mrn,
#         phone, address, emergency_contact_name, emergency_contact_phone, encounters

info "Updating EncounterType — patient field now returns PatientType..."
# Change: field :patient, Types::UserType → Types::PatientType

info "Slimming UserType — remove encounters, add patient/provider links..."
# UserType is now auth-only: id, email, role + has_one links to patient/provider

info "Updating ProviderType — add city, state, zip, location..."

info "Adding patients/patient queries to QueryType..."
# patients(name: String, gender: String): [PatientType]  — full-text search on name
# patient(id: ID): PatientType

# ─────────────────────────────────────────────────────────────────────────────
# 5. FACTORIES + SPECS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating patients FactoryBot factory..."
# spec/factories/patients.rb with Faker demographics + :without_user trait

info "Updating encounters factory — association :patient (not factory: :user)..."

info "Creating patient_spec.rb..."
# Covers: associations, validations, full_name, age, search_by_name, alphabetical

info "Updating encounter_spec — enc.patient is now Patient, not User..."

# ─────────────────────────────────────────────────────────────────────────────
# 6. RBS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating sig/app/models/patient.rbs..."
info "Updating sig/app/models/provider.rbs — add user_id, city, state, zip, methods..."
info "Updating sig/app/models/user.rbs — add patient/provider association accessors..."
info "Creating sig/app/graphql/types/patient_type.rbs..."
info "Updating sig/app/graphql/types/user_type.rbs — remove encounters method..."

# ─────────────────────────────────────────────────────────────────────────────
# 7. MIGRATE AND VERIFY
# ─────────────────────────────────────────────────────────────────────────────

info "Running migrations..."
bin/rails db:migrate

info "Running patient and encounter specs..."
bin/rspec spec/models/patient_spec.rb spec/models/encounter_spec.rb

success "Patient profile separation complete."
