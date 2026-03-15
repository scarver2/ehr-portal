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
