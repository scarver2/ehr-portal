#!/usr/bin/env bash
# bin/steps/13_active-admin.sh

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Adding ActiveAdmin..."
# Should already be installed bundle add devise
bundle add activeadmin
bundle add propshaft
bundle add dartsass-rails



# TODO: This may not be needed
# cat <<EOF > config/initializers/assets.rb
# # apps/ehr-api/config/initializers/assets.rb
# Rails.application.config.assets.precompile += %w(
#   active_admin.js
#   active_admin.css
# )
# EOF

# config/initializers/session_store.rb
# Rails.application.config.session_store :cookie_store, key: "_ehr_admin_session"

# config.action_dispatch.cookies_same_site_protection = :lax

# In config/initializers/devise.rb
# find and replace config.navigational_formats = ['*/*', :html, :turbo_stream]
# with config.navigational_formats = ['*/*', :html]

# In config/initializers/devise.rb
# find and replace config.site_title = "Ehr Api"
# with config.site_title = "EHR Admin"


# config/application.rb
bin/rails generate active_admin:install


# mkdir -p app/assets/stylesheets
# mkdir -p app/assets/javascripts

# touch app/assets/stylesheets/active_admin.css
# touch app/assets/javascripts/active_admin.js

# config/application.rb
# require "action_view/railtie"
# config.middleware.use ActionDispatch::Cookies
# config.middleware.use ActionDispatch::Session::CookieStore
# config.middleware.use ActionDispatch::Flash

# app/assets/stylesheets/active_admin.css
# /*
#  *= require active_admin/base
#  */

# app/assets/javascripts/active_admin.js
# //
# //= require active_admin/base
# //


# TODO: This may not be needed
# config/initializers/assets.rb
# Rails.application.config.assets.precompile += %w(
#   active_admin.js
#   active_admin.css
# )

# app/views/layouts/active_admin.html.erb
# <%= stylesheet_link_tag "active_admin", "data-turbo-track": "reload" %>
# <%= javascript_include_tag "active_admin", "data-turbo-track": "reload" %>

info "Adding Administrator user..."
# bin/rails generate devise:install
# bin/rails generate devise AdminUser

# In app/models/admin_user.rb
# insert after class AdminUser < ApplicationRecord
#   def self.ransackable_attributes(auth_object = nil)
#     ["created_at", "email", "encrypted_password", "id", "id_value", "remember_created_at", "reset_password_sent_at", "reset_password_token", "updated_at"]
#   end


# info "Migrating database..."
# bin/rails db:migrate

# TODO config ActiveAdmin to use Devise for authentication
