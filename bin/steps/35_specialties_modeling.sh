#!/usr/bin/env bash
# bin/steps/35_specialties_modeling.sh
#
# Introduce the Specialties domain model, replacing the legacy MEDICAL_SPECIALTIES
# string constant with a proper normalised table and AR association.
#
# Design rationale:
#   Provider previously stored specialty as a free-text string column.
#   Replacing it with a FK reference to a `specialties` table gives us:
#     • Consistent naming/casing across all providers
#     • Category grouping (Medical / Surgical / Primary Care)
#     • Admin UI for managing specialties without a code change
#     • Clean GraphQL exposure via SpecialtyType
#
# What changes:
#   1. New `specialties` table (name unique, category)
#   2. providers.specialty_id FK added; providers.specialty string dropped
#   3. Specialty model: validations, scopes (alphabetical, by_category), ransack
#   4. Provider model: belongs_to :specialty (optional), updated ransackable_attributes
#   5. ActiveAdmin: new specialties resource with provider count panel; providers
#      form updated to use Specialty.alphabetical collection
#   6. GraphQL: new SpecialtyType; ProviderType.specialty returns SpecialtyType;
#      QueryType adds specialties(category) and specialty(id) queries
#   7. Seeds: medical_specialties.rb rewritten to use Specialty.insert_all! with
#      31 records; providers.rb updated to use Specialty.all.sample
#   8. FactoryBot: specialties factory; providers factory updated to association :specialty
#   9. Specs: specialty_spec.rb; provider_spec.rb updated for new association
#  10. RBS: specialty.rbs; updated provider.rbs (specialty_id, specialty accessor)
#
# Schema additions:
#
#   specialties
#     name:       string NOT NULL UNIQUE
#     category:   string
#     indexes: name (unique), category
#
#   providers (changes)
#     specialty_id: bigint FK → specialties (nullable)  ← added
#     specialty:    string                               ← dropped

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

# ─────────────────────────────────────────────────────────────────────────────
# 1. MIGRATIONS
# ─────────────────────────────────────────────────────────────────────────────

info "Migration: create_specialties..."
# db/migrate/TIMESTAMP_create_specialties.rb
# Creates specialties table with name (NOT NULL UNIQUE), category, timestamps
# Indexes: name (unique), category

info "Migration: replace_provider_specialty_string_with_reference..."
# db/migrate/TIMESTAMP_replace_provider_specialty_string_with_reference.rb
# add_reference :providers, :specialty, foreign_key: true, null: true
# remove_column :providers, :specialty, :string

# ─────────────────────────────────────────────────────────────────────────────
# 2. MODELS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating Specialty model..."
# app/models/specialty.rb
#
#   class Specialty < ApplicationRecord
#     has_many :providers, dependent: :nullify, inverse_of: :specialty
#     validates :name, presence: true, uniqueness: { case_sensitive: false }
#     scope :alphabetical, -> { order(:name) }
#     scope :by_category,  ->(cat) { where(category: cat) }
#     ransackable_attributes: %w[category id name created_at updated_at]
#     ransackable_associations: %w[providers]
#   end

info "Updating Provider model..."
# Add:  belongs_to :specialty, optional: true, inverse_of: :providers
# Remove: no explicit specialty string attribute
# Update ransackable_attributes: replace "specialty" with "specialty_id"
# Update ransackable_associations: add "specialty"

# ─────────────────────────────────────────────────────────────────────────────
# 3. ACTIVE ADMIN
# ─────────────────────────────────────────────────────────────────────────────

info "Creating specialties ActiveAdmin resource..."
# app/admin/specialties.rb
# Filters: name, category
# Index: name, category, provider count column
# Show: attributes_table + providers panel
# Form: name, category (select from distinct values)

info "Updating providers ActiveAdmin resource..."
# permit_params: replace :specialty with :specialty_id
# Form: f.input :specialty, as: :select, collection: Specialty.alphabetical.map { |s| [s.name, s.id] }

# ─────────────────────────────────────────────────────────────────────────────
# 4. GRAPHQL
# ─────────────────────────────────────────────────────────────────────────────

info "Creating SpecialtyType GraphQL type..."
# app/graphql/types/specialty_type.rb
# Fields: id, name, category, created_at, updated_at
# implements NodeType

info "Updating ProviderType — specialty field now returns SpecialtyType..."
# Change: field :specialty, String  →  field :specialty, Types::SpecialtyType, null: true

info "Adding specialties/specialty queries to QueryType..."
# specialties(category: String): [SpecialtyType]
# specialty(id: ID): SpecialtyType

# ─────────────────────────────────────────────────────────────────────────────
# 5. SEEDS
# ─────────────────────────────────────────────────────────────────────────────

info "Rewriting medical_specialties seed..."
# db/seeds/medical_specialties.rb
# Uses Specialty.insert_all! with 31 records and unique_by: :name
# Replaces the legacy MEDICAL_SPECIALTIES constant array

info "Updating providers seed..."
# db/seeds/providers.rb
# Change: specialty: MEDICAL_SPECIALTIES.sample
# to:     specialty: Specialty.all.sample

# ─────────────────────────────────────────────────────────────────────────────
# 6. FACTORIES + SPECS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating specialties FactoryBot factory..."
# spec/factories/specialties.rb
# sequence name, random category from Medical/Surgical/Primary Care

info "Updating providers factory..."
# Change: specialty { 'Cardiology' }  →  association :specialty

info "Creating specialty_spec.rb..."
# Covers: validations (presence, uniqueness case-insensitive), associations
# (has_many providers, nullify on destroy), alphabetical scope, by_category scope,
# ransackable_attributes

info "Updating provider_spec.rb..."
# specialty assertion now checks for Specialty instance (not string)
# ransackable check: includes specialty_id, excludes specialty string

# ─────────────────────────────────────────────────────────────────────────────
# 7. RBS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating sig/app/models/specialty.rbs..."
info "Updating sig/app/models/provider.rbs — replace specialty: String with specialty_id + specialty method..."
info "Creating sig/app/graphql/types/specialty_type.rbs..."

# ─────────────────────────────────────────────────────────────────────────────
# 8. MIGRATE AND VERIFY
# ─────────────────────────────────────────────────────────────────────────────

info "Running migrations..."
DB_USER=ehr_api DB_PASSWORD='' bin/rails db:migrate

info "Running specialty and provider specs..."
DB_USER=ehr_api DB_PASSWORD='' bin/rspec spec/models/specialty_spec.rb spec/models/provider_spec.rb

success "Specialties modeling complete."
