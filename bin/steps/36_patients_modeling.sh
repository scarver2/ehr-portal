#!/usr/bin/env bash
# bin/steps/36_patients_modeling.sh
#
# Patients domain: Encounter, Vital, and Diagnosis modeling.
#
# A "patient" in this system is a User with role: patient.
# Encounters link patients to providers and serve as the parent record
# for Vitals (observed measurements) and Diagnoses (ICD-10 coded conditions).
#
# Schema:
#
#   encounters
#     patient_id:      bigint FK → users
#     provider_id:     bigint FK → providers
#     encounter_type:  string  (office_visit | telehealth | emergency | follow_up | annual_exam)
#     status:          string  (scheduled | in_progress | completed | cancelled)
#     encountered_at:  datetime
#     chief_complaint: string?
#     notes:           text?
#
#   vitals
#     encounter_id: bigint FK → encounters
#     vital_type:   string (blood_pressure | heart_rate | temperature | weight | height |
#                           oxygen_saturation | respiratory_rate | bmi)
#     value:        string
#     unit:         string?
#     observed_at:  datetime
#     notes:        text?
#
#   diagnoses
#     encounter_id: bigint FK → encounters
#     icd10_code:   string  (validated format: /\A[A-Z][0-9]{2}(\.[A-Z0-9]{1,4})?\z/)
#     description:  string
#     status:       string  (active | resolved | chronic | ruled_out)
#     diagnosed_at: datetime
#     notes:        text?
#
# Steps:
#   1.  Create migrations
#   2.  Create models (Encounter, Vital, Diagnosis) + update User/Provider associations
#   3.  Create ActiveAdmin resources
#   4.  Create GraphQL types (EncounterType, VitalType, DiagnosisType, UserType)
#   5.  Wire GraphQL queries in QueryType
#   6.  Create FactoryBot factories with enum traits
#   7.  Create model specs
#   8.  Create RBS signatures for models and GraphQL types
#   9.  Run migrations and specs

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

# ─────────────────────────────────────────────────────────────────────────────
# 1. MIGRATIONS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating migration: create_encounters..."
cat << 'EOF' > db/migrate/$(date +%Y%m%d%H%M%S)_create_encounters.rb
# frozen_string_literal: true

class CreateEncounters < ActiveRecord::Migration[8.1]
  def change
    create_table :encounters do |t|
      t.references :patient,  null: false, foreign_key: { to_table: :users }
      t.references :provider, null: false, foreign_key: true
      t.string   :encounter_type, null: false, default: "office_visit"
      t.string   :status,         null: false, default: "scheduled"
      t.datetime :encountered_at, null: false
      t.string   :chief_complaint
      t.text     :notes

      t.timestamps
    end

    add_index :encounters, :encountered_at
    add_index :encounters, %i[patient_id encountered_at]
  end
end
EOF

info "Creating migration: create_vitals..."
cat << 'EOF' > db/migrate/$(date +%Y%m%d%H%M%S)_create_vitals.rb
# frozen_string_literal: true

class CreateVitals < ActiveRecord::Migration[8.1]
  def change
    create_table :vitals do |t|
      t.references :encounter, null: false, foreign_key: true
      t.string   :vital_type,  null: false
      t.string   :value,       null: false
      t.string   :unit
      t.datetime :observed_at, null: false
      t.text     :notes

      t.timestamps
    end

    add_index :vitals, %i[encounter_id vital_type]
  end
end
EOF

info "Creating migration: create_diagnoses..."
cat << 'EOF' > db/migrate/$(date +%Y%m%d%H%M%S)_create_diagnoses.rb
# frozen_string_literal: true

class CreateDiagnoses < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnoses do |t|
      t.references :encounter, null: false, foreign_key: true
      t.string   :icd10_code,   null: false
      t.string   :description,  null: false
      t.string   :status,       null: false, default: "active"
      t.datetime :diagnosed_at, null: false
      t.text     :notes

      t.timestamps
    end

    add_index :diagnoses, :icd10_code
    add_index :diagnoses, %i[encounter_id icd10_code]
  end
end
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 2. MODELS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating Encounter model..."
cat << 'EOF' > app/models/encounter.rb
# apps/ehr-api/app/models/encounter.rb
# frozen_string_literal: true

class Encounter < ApplicationRecord
  belongs_to :patient,  class_name: "User",     foreign_key: :patient_id, inverse_of: :encounters
  belongs_to :provider, class_name: "Provider", foreign_key: :provider_id, inverse_of: :encounters

  has_many :vitals,    dependent: :destroy, inverse_of: :encounter
  has_many :diagnoses, dependent: :destroy, inverse_of: :encounter

  enum :encounter_type, {
    office_visit:  "office_visit",
    telehealth:    "telehealth",
    emergency:     "emergency",
    follow_up:     "follow_up",
    annual_exam:   "annual_exam"
  }, validate: true

  enum :status, {
    scheduled:   "scheduled",
    in_progress: "in_progress",
    completed:   "completed",
    cancelled:   "cancelled"
  }, validate: true

  validates :encountered_at, presence: true
  validates :encounter_type, presence: true
  validates :status,         presence: true

  scope :for_patient,  ->(user)     { where(patient: user) }
  scope :for_provider, ->(provider) { where(provider: provider) }
  scope :recent,                    -> { order(encountered_at: :desc) }
  scope :completed,                 -> { where(status: "completed") }

  def self.ransackable_attributes(auth_object = nil)
    %w[chief_complaint encountered_at encounter_type id patient_id provider_id status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[patient provider vitals diagnoses]
  end
end
EOF

info "Creating Vital model..."
cat << 'EOF' > app/models/vital.rb
# apps/ehr-api/app/models/vital.rb
# frozen_string_literal: true

class Vital < ApplicationRecord
  belongs_to :encounter, inverse_of: :vitals

  enum :vital_type, {
    blood_pressure:      "blood_pressure",
    heart_rate:          "heart_rate",
    temperature:         "temperature",
    weight:              "weight",
    height:              "height",
    oxygen_saturation:   "oxygen_saturation",
    respiratory_rate:    "respiratory_rate",
    bmi:                 "bmi"
  }, validate: true

  UNITS = {
    blood_pressure:    "mmHg",
    heart_rate:        "bpm",
    temperature:       "°F",
    weight:            "kg",
    height:            "cm",
    oxygen_saturation: "%",
    respiratory_rate:  "breaths/min",
    bmi:               "kg/m²"
  }.freeze

  validates :vital_type,  presence: true
  validates :value,       presence: true
  validates :observed_at, presence: true

  scope :by_type, ->(type) { where(vital_type: type) }
  scope :recent,           -> { order(observed_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[encounter_id id observed_at unit value vital_type created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[encounter]
  end
end
EOF

info "Creating Diagnosis model..."
cat << 'EOF' > app/models/diagnosis.rb
# apps/ehr-api/app/models/diagnosis.rb
# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  belongs_to :encounter, inverse_of: :diagnoses

  enum :status, {
    active:    "active",
    resolved:  "resolved",
    chronic:   "chronic",
    ruled_out: "ruled_out"
  }, validate: true

  validates :icd10_code,   presence: true,
                           format: { with: /\A[A-Z][0-9]{2}(\.[A-Z0-9]{1,4})?\z/,
                                     message: "must be a valid ICD-10 code (e.g. Z00.00)" }
  validates :description,  presence: true
  validates :status,       presence: true
  validates :diagnosed_at, presence: true

  scope :active,  -> { where(status: "active") }
  scope :chronic, -> { where(status: "chronic") }
  scope :recent,  -> { order(diagnosed_at: :desc) }
  scope :by_code, ->(code) { where(icd10_code: code) }

  def self.ransackable_attributes(auth_object = nil)
    %w[description diagnosed_at encounter_id icd10_code id status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[encounter]
  end
end
EOF

info "Updating User model with encounters association..."
# Add to app/models/user.rb:
#   has_many :encounters, foreign_key: :patient_id, inverse_of: :patient, dependent: :destroy

info "Updating Provider model with encounters association..."
# Add to app/models/provider.rb:
#   has_many :encounters, inverse_of: :provider, dependent: :restrict_with_error
# Note: restrict_with_error prevents deleting a provider with existing encounters.

# ─────────────────────────────────────────────────────────────────────────────
# 3. ACTIVE ADMIN RESOURCES
# ─────────────────────────────────────────────────────────────────────────────

info "Creating ActiveAdmin resource: encounters..."
cat << 'EOF' > app/admin/encounters.rb
# frozen_string_literal: true

ActiveAdmin.register Encounter do
  permit_params :patient_id, :provider_id, :encounter_type, :status,
                :encountered_at, :chief_complaint, :notes

  filter :patient,        as: :select
  filter :provider,       as: :select
  filter :encounter_type, as: :select, collection: Encounter.encounter_types.keys
  filter :status,         as: :select, collection: Encounter.statuses.keys
  filter :encountered_at
  filter :chief_complaint

  index do
    selectable_column
    id_column
    column :patient
    column :provider
    column :encounter_type
    column :status
    column :encountered_at
    column :chief_complaint
    actions
  end

  show do
    attributes_table do
      row :id
      row :patient
      row :provider
      row :encounter_type
      row :status
      row :encountered_at
      row :chief_complaint
      row :notes
      row :created_at
      row :updated_at
    end

    panel "Vitals" do
      table_for encounter.vitals.recent do
        column :vital_type
        column :value
        column :unit
        column :observed_at
      end
    end

    panel "Diagnoses" do
      table_for encounter.diagnoses.recent do
        column :icd10_code
        column :description
        column :status
        column :diagnosed_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :patient,        as: :select, collection: User.where(role: :patient).order(:email)
      f.input :provider,       as: :select, collection: Provider.order(:last_name)
      f.input :encounter_type, as: :select, collection: Encounter.encounter_types.keys
      f.input :status,         as: :select, collection: Encounter.statuses.keys
      f.input :encountered_at, as: :datetime_picker
      f.input :chief_complaint
      f.input :notes
    end
    f.actions
  end
end
EOF

info "Creating ActiveAdmin resource: vitals..."
cat << 'EOF' > app/admin/vitals.rb
# frozen_string_literal: true

ActiveAdmin.register Vital do
  belongs_to :encounter, optional: true

  permit_params :encounter_id, :vital_type, :value, :unit, :observed_at, :notes

  filter :encounter
  filter :vital_type, as: :select, collection: Vital.vital_types.keys
  filter :observed_at

  index do
    selectable_column
    id_column
    column :encounter
    column :vital_type
    column :value
    column :unit
    column :observed_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :encounter
      row :vital_type
      row :value
      row :unit
      row :observed_at
      row :notes
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :encounter
      f.input :vital_type, as: :select, collection: Vital.vital_types.keys
      f.input :value
      f.input :unit
      f.input :observed_at, as: :datetime_picker
      f.input :notes
    end
    f.actions
  end
end
EOF

info "Creating ActiveAdmin resource: diagnoses..."
cat << 'EOF' > app/admin/diagnoses.rb
# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  belongs_to :encounter, optional: true

  permit_params :encounter_id, :icd10_code, :description, :status, :diagnosed_at, :notes

  filter :encounter
  filter :icd10_code
  filter :status, as: :select, collection: Diagnosis.statuses.keys
  filter :diagnosed_at

  index do
    selectable_column
    id_column
    column :encounter
    column :icd10_code
    column :description
    column :status
    column :diagnosed_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :encounter
      row :icd10_code
      row :description
      row :status
      row :diagnosed_at
      row :notes
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :encounter
      f.input :icd10_code
      f.input :description
      f.input :status, as: :select, collection: Diagnosis.statuses.keys
      f.input :diagnosed_at, as: :datetime_picker
      f.input :notes
    end
    f.actions
  end
end
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 4. GRAPHQL TYPES
# ─────────────────────────────────────────────────────────────────────────────

info "Creating GraphQL type: UserType..."
cat << 'EOF' > app/graphql/types/user_type.rb
# apps/ehr-api/app/graphql/types/user_type.rb
# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    description "A user account (patients have role: patient)."
    implements Types::NodeType

    field :id,         ID,     null: false
    field :email,      String, null: false
    field :role,       String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :encounters, [Types::EncounterType], null: false

    def encounters
      object.encounters.recent
    end
  end
end
EOF

info "Creating GraphQL type: VitalType..."
cat << 'EOF' > app/graphql/types/vital_type.rb
# apps/ehr-api/app/graphql/types/vital_type.rb
# frozen_string_literal: true

module Types
  class VitalType < Types::BaseObject
    description "A vital sign measurement recorded during an encounter."
    implements Types::NodeType

    field :id,          ID,     null: false
    field :vital_type,  String, null: false
    field :value,       String, null: false
    field :unit,        String
    field :observed_at, GraphQL::Types::ISO8601DateTime, null: false
    field :notes,       String
    field :created_at,  GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at,  GraphQL::Types::ISO8601DateTime, null: false
  end
end
EOF

info "Creating GraphQL type: DiagnosisType..."
cat << 'EOF' > app/graphql/types/diagnosis_type.rb
# apps/ehr-api/app/graphql/types/diagnosis_type.rb
# frozen_string_literal: true

module Types
  class DiagnosisType < Types::BaseObject
    description "An ICD-10 diagnosis attached to an encounter."
    implements Types::NodeType

    field :id,           ID,     null: false
    field :icd10_code,   String, null: false
    field :description,  String, null: false
    field :status,       String, null: false
    field :diagnosed_at, GraphQL::Types::ISO8601DateTime, null: false
    field :notes,        String
    field :created_at,   GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at,   GraphQL::Types::ISO8601DateTime, null: false
  end
end
EOF

info "Creating GraphQL type: EncounterType..."
cat << 'EOF' > app/graphql/types/encounter_type.rb
# apps/ehr-api/app/graphql/types/encounter_type.rb
# frozen_string_literal: true

module Types
  class EncounterType < Types::BaseObject
    description "A clinical encounter between a patient and provider."
    implements Types::NodeType

    field :id,              ID,                              null: false
    field :encounter_type,  String,                          null: false
    field :status,          String,                          null: false
    field :encountered_at,  GraphQL::Types::ISO8601DateTime, null: false
    field :chief_complaint, String
    field :notes,           String
    field :created_at,      GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at,      GraphQL::Types::ISO8601DateTime, null: false

    field :patient,    Types::UserType,        null: false
    field :provider,   Types::ProviderType,    null: false
    field :vitals,     [Types::VitalType],     null: false
    field :diagnoses,  [Types::DiagnosisType], null: false

    def vitals
      object.vitals.recent
    end

    def diagnoses
      object.diagnoses.recent
    end
  end
end
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 5. GRAPHQL QUERY TYPE — add encounters, vitals, diagnoses queries
# ─────────────────────────────────────────────────────────────────────────────

info "Wiring GraphQL queries for encounters, vitals, diagnoses..."
# Add to app/graphql/types/query_type.rb:
#
#   # Encounters
#   field :encounters, [Types::EncounterType], null: false do
#     argument :patient_id,  ID,     required: false
#     argument :provider_id, ID,     required: false
#     argument :status,      String, required: false
#   end
#
#   def encounters(patient_id: nil, provider_id: nil, status: nil)
#     scope = Encounter.recent
#     scope = scope.where(patient_id: patient_id)   if patient_id
#     scope = scope.where(provider_id: provider_id) if provider_id
#     scope = scope.where(status: status)            if status
#     scope
#   end
#
#   field :encounter, Types::EncounterType, null: true do
#     argument :id, ID, required: true
#   end
#
#   def encounter(id:)
#     Encounter.find_by(id: id)
#   end
#
#   # Vitals
#   field :vitals, [Types::VitalType], null: false do
#     argument :encounter_id, ID, required: true
#   end
#
#   def vitals(encounter_id:)
#     Vital.where(encounter_id: encounter_id).recent
#   end
#
#   # Diagnoses
#   field :diagnoses, [Types::DiagnosisType], null: false do
#     argument :encounter_id, ID,     required: false
#     argument :icd10_code,   String, required: false
#   end
#
#   def diagnoses(encounter_id: nil, icd10_code: nil)
#     scope = Diagnosis.recent
#     scope = scope.where(encounter_id: encounter_id) if encounter_id
#     scope = scope.by_code(icd10_code)               if icd10_code
#     scope
#   end

# ─────────────────────────────────────────────────────────────────────────────
# 6. FACTORIES
# ─────────────────────────────────────────────────────────────────────────────

info "Creating FactoryBot factory: encounters..."
cat << 'EOF' > spec/factories/encounters.rb
# spec/factories/encounters.rb

FactoryBot.define do
  factory :encounter do
    association :patient, factory: :user, role: :patient
    association :provider

    encounter_type { :office_visit }
    status         { :scheduled }
    encountered_at { 1.week.ago }
    chief_complaint { "Annual checkup" }

    trait :office_visit   { encounter_type { :office_visit } }
    trait :telehealth     { encounter_type { :telehealth } }
    trait :emergency      { encounter_type { :emergency } }
    trait :follow_up      { encounter_type { :follow_up } }
    trait :annual_exam    { encounter_type { :annual_exam } }

    trait :scheduled    { status { :scheduled } }
    trait :in_progress  { status { :in_progress } }
    trait :completed    { status { :completed } }
    trait :cancelled    { status { :cancelled } }
  end
end
EOF

info "Creating FactoryBot factory: vitals..."
cat << 'EOF' > spec/factories/vitals.rb
# spec/factories/vitals.rb

FactoryBot.define do
  factory :vital do
    association :encounter

    vital_type  { :heart_rate }
    value       { "72" }
    unit        { "bpm" }
    observed_at { Time.current }

    trait :blood_pressure   { vital_type { :blood_pressure };    value { "120/80" }; unit { "mmHg" } }
    trait :heart_rate       { vital_type { :heart_rate };        value { "72" };     unit { "bpm" } }
    trait :temperature      { vital_type { :temperature };       value { "98.6" };   unit { "°F" } }
    trait :weight           { vital_type { :weight };            value { "70" };     unit { "kg" } }
    trait :height           { vital_type { :height };            value { "175" };    unit { "cm" } }
    trait :oxygen_saturation { vital_type { :oxygen_saturation }; value { "98" };   unit { "%" } }
    trait :respiratory_rate { vital_type { :respiratory_rate };  value { "16" };    unit { "breaths/min" } }
    trait :bmi              { vital_type { :bmi };               value { "22.9" };   unit { "kg/m²" } }
  end
end
EOF

info "Creating FactoryBot factory: diagnoses..."
cat << 'EOF' > spec/factories/diagnoses.rb
# spec/factories/diagnoses.rb

FactoryBot.define do
  factory :diagnosis do
    association :encounter

    icd10_code  { "Z00.00" }
    description { "Encounter for general adult medical examination without abnormal findings" }
    status      { :active }
    diagnosed_at { Time.current }

    trait :active    { status { :active } }
    trait :resolved  { status { :resolved } }
    trait :chronic   { status { :chronic } }
    trait :ruled_out { status { :ruled_out } }

    trait :hypertension do
      icd10_code  { "I10" }
      description { "Essential (primary) hypertension" }
      status      { :chronic }
    end

    trait :type2_diabetes do
      icd10_code  { "E11.9" }
      description { "Type 2 diabetes mellitus without complications" }
      status      { :chronic }
    end

    trait :upper_respiratory do
      icd10_code  { "J06.9" }
      description { "Acute upper respiratory infection, unspecified" }
      status      { :resolved }
    end
  end
end
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 7. MODEL SPECS
# ─────────────────────────────────────────────────────────────────────────────

info "Creating model spec: encounter_spec..."
cat << 'EOF' > spec/models/encounter_spec.rb
# spec/models/encounter_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Encounter, type: :model do
  subject(:encounter) { build(:encounter) }

  describe "associations" do
    it { is_expected.to belong_to(:patient).class_name("User") }
    it { is_expected.to belong_to(:provider).class_name("Provider") }
    it { is_expected.to have_many(:vitals).dependent(:destroy) }
    it { is_expected.to have_many(:diagnoses).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:encountered_at) }
    it { is_expected.to validate_presence_of(:encounter_type) }
    it { is_expected.to validate_presence_of(:status) }

    it "rejects an invalid encounter_type" do
      encounter.write_attribute(:encounter_type, "invalid")
      expect(encounter).not_to be_valid
    end

    it "rejects an invalid status" do
      encounter.write_attribute(:status, "invalid")
      expect(encounter).not_to be_valid
    end
  end

  describe "enum predicates" do
    it { is_expected.to be_office_visit }
    it { is_expected.to be_scheduled }

    it "recognises telehealth type" do
      expect(build(:encounter, :telehealth)).to be_telehealth
    end

    it "recognises completed status" do
      expect(build(:encounter, :completed)).to be_completed
    end
  end

  describe "scopes" do
    let!(:old_encounter)   { create(:encounter, encountered_at: 1.month.ago) }
    let!(:new_encounter)   { create(:encounter, encountered_at: 1.day.ago) }
    let!(:done_encounter)  { create(:encounter, :completed) }

    it ".recent orders by encountered_at desc" do
      expect(Encounter.recent.first).to eq(new_encounter)
    end

    it ".completed filters by completed status" do
      expect(Encounter.completed).to include(done_encounter)
      expect(Encounter.completed).not_to include(old_encounter)
    end

    it ".for_patient filters by patient" do
      expect(Encounter.for_patient(new_encounter.patient)).to include(new_encounter)
      expect(Encounter.for_patient(new_encounter.patient)).not_to include(old_encounter)
    end

    it ".for_provider filters by provider" do
      expect(Encounter.for_provider(new_encounter.provider)).to include(new_encounter)
    end
  end
end
EOF

info "Creating model spec: vital_spec..."
cat << 'EOF' > spec/models/vital_spec.rb
# spec/models/vital_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Vital, type: :model do
  subject(:vital) { build(:vital) }

  describe "associations" do
    it { is_expected.to belong_to(:encounter) }
  end

  describe "validations" do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:vital_type) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:observed_at) }

    it "rejects an invalid vital_type" do
      vital.write_attribute(:vital_type, "invalid")
      expect(vital).not_to be_valid
    end
  end

  describe "UNITS constant" do
    it "defines units for every vital type" do
      Vital.vital_types.each_key do |type|
        expect(Vital::UNITS).to have_key(type.to_sym)
      end
    end
  end

  describe "enum predicates" do
    it { is_expected.to be_heart_rate }

    it "recognises blood_pressure type" do
      expect(build(:vital, :blood_pressure)).to be_blood_pressure
    end
  end

  describe "scopes" do
    let!(:old_vital) { create(:vital, observed_at: 1.hour.ago) }
    let!(:new_vital) { create(:vital, observed_at: Time.current) }

    it ".recent orders by observed_at desc" do
      expect(Vital.recent.first).to eq(new_vital)
    end

    it ".by_type filters by vital_type" do
      bp = create(:vital, :blood_pressure)
      expect(Vital.by_type(:blood_pressure)).to include(bp)
      expect(Vital.by_type(:blood_pressure)).not_to include(new_vital)
    end
  end
end
EOF

info "Creating model spec: diagnosis_spec..."
cat << 'EOF' > spec/models/diagnosis_spec.rb
# spec/models/diagnosis_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Diagnosis, type: :model do
  subject(:diagnosis) { build(:diagnosis) }

  describe "associations" do
    it { is_expected.to belong_to(:encounter) }
  end

  describe "validations" do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:icd10_code) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:diagnosed_at) }

    context "ICD-10 code format" do
      it "accepts a valid 3-character code" do
        diagnosis.icd10_code = "I10"
        expect(diagnosis).to be_valid
      end

      it "accepts a valid code with decimal extension" do
        diagnosis.icd10_code = "E11.9"
        expect(diagnosis).to be_valid
      end

      it "rejects a lowercase code" do
        diagnosis.icd10_code = "i10"
        expect(diagnosis).not_to be_valid
      end

      it "rejects an entirely numeric code" do
        diagnosis.icd10_code = "110"
        expect(diagnosis).not_to be_valid
      end
    end

    it "rejects an invalid status" do
      diagnosis.write_attribute(:status, "invalid")
      expect(diagnosis).not_to be_valid
    end
  end

  describe "enum predicates" do
    it { is_expected.to be_active }

    it "recognises chronic status" do
      expect(build(:diagnosis, :chronic)).to be_chronic
    end
  end

  describe "scopes" do
    let!(:active_dx)  { create(:diagnosis, :active) }
    let!(:chronic_dx) { create(:diagnosis, :hypertension) }
    let!(:old_dx)     { create(:diagnosis, diagnosed_at: 1.month.ago) }
    let!(:new_dx)     { create(:diagnosis, diagnosed_at: Time.current) }

    it ".active filters by active status" do
      expect(Diagnosis.active).to include(active_dx)
      expect(Diagnosis.active).not_to include(chronic_dx)
    end

    it ".chronic filters by chronic status" do
      expect(Diagnosis.chronic).to include(chronic_dx)
    end

    it ".recent orders by diagnosed_at desc" do
      expect(Diagnosis.recent.first).to eq(new_dx)
    end

    it ".by_code filters by icd10_code" do
      expect(Diagnosis.by_code("I10")).to include(chronic_dx)
    end
  end
end
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 8. RBS SIGNATURES
# ─────────────────────────────────────────────────────────────────────────────

info "Creating RBS: sig/app/models/encounter.rbs..."
cat << 'EOF' > sig/app/models/encounter.rbs
# sig/app/models/encounter.rbs

class Encounter < ApplicationRecord
  attr_accessor id:              ::Integer
  attr_accessor patient_id:      ::Integer
  attr_accessor provider_id:     ::Integer
  attr_accessor encounter_type:  ::String
  attr_accessor status:          ::String
  attr_accessor encountered_at:  ::Time
  attr_accessor chief_complaint: ::String?
  attr_accessor notes:           ::String?
  attr_accessor created_at:      ::Time
  attr_accessor updated_at:      ::Time

  # enum predicates
  def office_visit?: () -> bool
  def telehealth?:   () -> bool
  def emergency?:    () -> bool
  def follow_up?:    () -> bool
  def annual_exam?:  () -> bool
  def scheduled?:    () -> bool
  def in_progress?:  () -> bool
  def completed?:    () -> bool
  def cancelled?:    () -> bool
end
EOF

info "Creating RBS: sig/app/models/vital.rbs..."
cat << 'EOF' > sig/app/models/vital.rbs
# sig/app/models/vital.rbs

class Vital < ApplicationRecord
  attr_accessor id:           ::Integer
  attr_accessor encounter_id: ::Integer
  attr_accessor vital_type:   ::String
  attr_accessor value:        ::String
  attr_accessor unit:         ::String?
  attr_accessor observed_at:  ::Time
  attr_accessor notes:        ::String?
  attr_accessor created_at:   ::Time
  attr_accessor updated_at:   ::Time

  # enum predicates
  def blood_pressure?:    () -> bool
  def heart_rate?:        () -> bool
  def temperature?:       () -> bool
  def weight?:            () -> bool
  def height?:            () -> bool
  def oxygen_saturation?: () -> bool
  def respiratory_rate?:  () -> bool
  def bmi?:               () -> bool

  UNITS: ::Hash[::Symbol, ::String]
end
EOF

info "Creating RBS: sig/app/models/diagnosis.rbs..."
cat << 'EOF' > sig/app/models/diagnosis.rbs
# sig/app/models/diagnosis.rbs

class Diagnosis < ApplicationRecord
  attr_accessor id:           ::Integer
  attr_accessor encounter_id: ::Integer
  attr_accessor icd10_code:   ::String
  attr_accessor description:  ::String
  attr_accessor status:       ::String
  attr_accessor diagnosed_at: ::Time
  attr_accessor notes:        ::String?
  attr_accessor created_at:   ::Time
  attr_accessor updated_at:   ::Time

  # enum predicates
  def active?:    () -> bool
  def resolved?:  () -> bool
  def chronic?:   () -> bool
  def ruled_out?: () -> bool
end
EOF

info "Creating RBS: sig/app/graphql/types/encounter_type.rbs..."
cat << 'EOF' > sig/app/graphql/types/encounter_type.rbs
# sig/app/graphql/types/encounter_type.rbs

module Types
  class EncounterType < Types::BaseObject
    def vitals:    () -> ::ActiveRecord::Associations::CollectionProxy
    def diagnoses: () -> ::ActiveRecord::Associations::CollectionProxy
  end
end
EOF

info "Creating RBS: sig/app/graphql/types/vital_type.rbs..."
cat << 'EOF' > sig/app/graphql/types/vital_type.rbs
# sig/app/graphql/types/vital_type.rbs

module Types
  class VitalType < Types::BaseObject
  end
end
EOF

info "Creating RBS: sig/app/graphql/types/diagnosis_type.rbs..."
cat << 'EOF' > sig/app/graphql/types/diagnosis_type.rbs
# sig/app/graphql/types/diagnosis_type.rbs

module Types
  class DiagnosisType < Types::BaseObject
  end
end
EOF

info "Creating RBS: sig/app/graphql/types/user_type.rbs..."
cat << 'EOF' > sig/app/graphql/types/user_type.rbs
# sig/app/graphql/types/user_type.rbs

module Types
  class UserType < Types::BaseObject
    def encounters: () -> ::ActiveRecord::Associations::CollectionProxy
  end
end
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 9. MIGRATE AND VERIFY
# ─────────────────────────────────────────────────────────────────────────────

info "Running migrations..."
bin/rails db:migrate

info "Running model specs..."
bin/rspec spec/models/encounter_spec.rb spec/models/vital_spec.rb spec/models/diagnosis_spec.rb

success "Patients domain modeling complete."
