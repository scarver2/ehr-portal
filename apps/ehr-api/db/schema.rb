# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_22_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "email_auth_token"
    t.integer "failed_login_attempts", default: 0
    t.datetime "last_activity_at"
    t.string "last_activity_ip"
    t.datetime "last_login_at"
    t.string "last_login_ip"
    t.datetime "locked_until"
    t.string "password_hash", null: false
    t.datetime "reset_password_deadline"
    t.datetime "reset_password_email_sent_at"
    t.string "reset_password_key"
    t.string "status", default: "unverified", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verify_login_change_deadline"
    t.string "verify_login_change_key"
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password"
    t.datetime "updated_at", null: false
  end

  create_table "diagnoses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.datetime "diagnosed_at", null: false
    t.bigint "encounter_id", null: false
    t.string "icd10_code", null: false
    t.text "notes"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["encounter_id", "icd10_code"], name: "index_diagnoses_on_encounter_id_and_icd10_code"
    t.index ["encounter_id"], name: "index_diagnoses_on_encounter_id"
    t.index ["icd10_code"], name: "index_diagnoses_on_icd10_code"
  end

  create_table "encounters", force: :cascade do |t|
    t.string "chief_complaint"
    t.datetime "created_at", null: false
    t.string "encounter_type", default: "office_visit", null: false
    t.datetime "encountered_at", null: false
    t.text "notes"
    t.bigint "patient_id", null: false
    t.bigint "provider_id", null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "updated_at", null: false
    t.index ["encountered_at"], name: "index_encounters_on_encountered_at"
    t.index ["patient_id", "encountered_at"], name: "index_encounters_on_patient_id_and_encountered_at"
    t.index ["patient_id"], name: "index_encounters_on_patient_id"
    t.index ["provider_id"], name: "index_encounters_on_provider_id"
  end

  create_table "insurance_profiles", force: :cascade do |t|
    t.decimal "copay"
    t.datetime "created_at", null: false
    t.decimal "deductible"
    t.string "member_id"
    t.decimal "oop_max"
    t.bigint "payer_id", null: false
    t.string "payer_name"
    t.jsonb "raw_response", default: {}
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verified_at"
    t.index ["payer_id"], name: "index_insurance_profiles_on_payer_id"
    t.index ["user_id"], name: "index_insurance_profiles_on_user_id"
  end

  create_table "insurance_verifications", force: :cascade do |t|
    t.integer "copay_cents"
    t.datetime "created_at", null: false
    t.integer "deductible_cents"
    t.text "error_message"
    t.datetime "expires_at"
    t.string "external_reference"
    t.bigint "insurance_profile_id", null: false
    t.integer "oop_max_cents"
    t.string "payer_name"
    t.string "plan_name"
    t.jsonb "raw_response", default: {}, null: false
    t.string "request_uuid", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verified_at"
    t.index ["insurance_profile_id"], name: "index_insurance_verifications_on_insurance_profile_id"
    t.index ["request_uuid"], name: "index_insurance_verifications_on_request_uuid", unique: true
    t.index ["status"], name: "index_insurance_verifications_on_status"
    t.index ["user_id"], name: "index_insurance_verifications_on_user_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "emergency_contact_name"
    t.string "emergency_contact_phone"
    t.string "first_name", null: false
    t.string "gender"
    t.string "last_name", null: false
    t.string "mrn"
    t.string "phone"
    t.string "photo_url", comment: "URL to patient's profile photo"
    t.virtual "searchable_name", type: :tsvector, as: "to_tsvector('simple'::regconfig, (((COALESCE(first_name, ''::character varying))::text || ' '::text) || (COALESCE(last_name, ''::character varying))::text))", stored: true
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["last_name", "first_name"], name: "index_patients_on_last_name_and_first_name"
    t.index ["mrn"], name: "index_patients_on_mrn", unique: true
    t.index ["photo_url"], name: "index_patients_on_photo_url"
    t.index ["searchable_name"], name: "index_patients_on_searchable_name", using: :gin
    t.index ["user_id"], name: "index_patients_on_user_id", unique: true
  end

  create_table "payers", force: :cascade do |t|
    t.boolean "active"
    t.string "api_endpoint"
    t.string "clearinghouse"
    t.datetime "created_at", null: false
    t.jsonb "metadata"
    t.string "name"
    t.string "payer_code"
    t.boolean "requires_auth"
    t.integer "response_time_ms"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_payers_on_active"
    t.index ["payer_code"], name: "index_payers_on_payer_code", unique: true
  end

  create_table "providers", force: :cascade do |t|
    t.string "city"
    t.string "clinic_name"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "npi"
    t.string "photo_url", comment: "URL to provider's profile photo headshot"
    t.bigint "specialty_id"
    t.string "state"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "zip"
    t.index ["photo_url"], name: "index_providers_on_photo_url"
    t.index ["specialty_id"], name: "index_providers_on_specialty_id"
    t.index ["user_id"], name: "index_providers_on_user_id", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "specialties", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_specialties_on_category"
    t.index ["name"], name: "index_specialties_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "vitals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "encounter_id", null: false
    t.text "notes"
    t.datetime "observed_at", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.string "vital_type", null: false
    t.index ["encounter_id", "vital_type"], name: "index_vitals_on_encounter_id_and_vital_type"
    t.index ["encounter_id"], name: "index_vitals_on_encounter_id"
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "diagnoses", "encounters"
  add_foreign_key "encounters", "patients"
  add_foreign_key "encounters", "providers"
  add_foreign_key "insurance_profiles", "payers"
  add_foreign_key "insurance_profiles", "users"
  add_foreign_key "insurance_verifications", "insurance_profiles"
  add_foreign_key "insurance_verifications", "users"
  add_foreign_key "patients", "users"
  add_foreign_key "providers", "specialties"
  add_foreign_key "providers", "users"
  add_foreign_key "vitals", "encounters"
end
