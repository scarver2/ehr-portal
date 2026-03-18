# bin/steps/30_administrators_modeling.sh

info "Adding AdminUser model..."

bin/rails generate devise AdminUser

# TODO: Add ransack configuration to AdminUser
# In app/models/admin_user.rb
# insert after class AdminUser < ApplicationRecord
#   def self.ransackable_attributes(auth_object = nil)
#     ["created_at", "email", "encrypted_password", "id", "id_value", "remember_created_at", "reset_password_sent_at", "reset_password_token", "updated_at"]
#   end

# TODO config ActiveAdmin to use Devise for authentication
# insert commands

# info "Migrating database..."
# bin/rails db:migrate

# TODO: add AdminUser specs

info "Adding AdminUser RBS type signature..."
cat << 'EOF' > sig/app/models/admin_user.rbs
# sig/app/models/admin_user.rbs
# Column types derived from db/schema.rb (admin_users table).
# AR generates attribute accessors dynamically; attr_accessor syntax avoids
# Ruby::MethodDefinitionMissing under all_error. Predicate methods (_?) are
# omitted — they exist at runtime but cannot be declared without triggering
# the same diagnostic.

class AdminUser < ApplicationRecord
  attr_accessor id: ::Integer
  attr_accessor email: ::String
  attr_accessor encrypted_password: ::String
  attr_accessor reset_password_token: ::String?
  attr_accessor reset_password_sent_at: ::Time?
  attr_accessor remember_created_at: ::Time?
  attr_accessor created_at: ::Time
  attr_accessor updated_at: ::Time

  def self.ransackable_attributes: (?untyped auth_object) -> ::Array[::String]
end
EOF
