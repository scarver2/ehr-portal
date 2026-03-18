#!/usr/bin/env bash
# bin/steps/30_users_modeling.sh

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Adding role enum to User model..."

# TODO: Add `role` string column to the Devise users migration:
#   t.string :role, null: false, default: "patient"

# TODO: In app/models/user.rb, add:
#   include Pundit::Authorization
#
#   enum :role, {
#     admin:    "admin",
#     provider: "provider",
#     staff:    "staff",
#     patient:  "patient"
#   }, validate: true
#
#   validates :role, presence: true

info "Generating Pundit application policy..."
bin/rails generate pundit:install

info "Updating User RBS type signature..."
cat << 'EOF' > sig/app/models/user.rbs
# sig/app/models/user.rbs
# Column types derived from db/migrate (users table).
# AR generates attribute accessors dynamically; attr_accessor syntax avoids
# Ruby::MethodDefinitionMissing under all_error. Devise runtime methods
# (valid_password?, authenticate, etc.) remain untyped until devise ships
# official RBS definitions. Enum predicate methods are declared explicitly.

class User < ApplicationRecord
  ROLES: ::Array[::String]

  attr_accessor id: ::Integer
  attr_accessor email: ::String
  attr_accessor encrypted_password: ::String
  attr_accessor reset_password_token: ::String?
  attr_accessor reset_password_sent_at: ::Time?
  attr_accessor remember_created_at: ::Time?
  attr_accessor role: ::String
  attr_accessor created_at: ::Time
  attr_accessor updated_at: ::Time

  def admin?: () -> bool
  def provider?: () -> bool
  def staff?: () -> bool
  def patient?: () -> bool
end
EOF
