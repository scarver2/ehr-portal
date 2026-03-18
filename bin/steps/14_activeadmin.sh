#!/usr/bin/env bash
# bin/steps/13_active-admin.sh

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

info "Adding ActiveAdmin..."
# Should already be installed bundle add devise
bundle add activeadmin


info "Configuring Rails to serve ActiveAdmin..."
# In apps/ehr-api/app/controllers/application_controller.rb
# replace class ApplicationController < ActionController::API
# with class ApplicationController < ActionController::Base

info "Adding asset pipeline..."
bundle add propshaft
bundle add dartsass-rails
# TODO: Append to Procfile.dev
# apps/ehr-api/Procfile.dev
# css: bin/rails dartsass:watch

# TODO: In apps/ehr-api/config/application.rb
# replace config.api_only = true with config.api_only = false
# require "action_view/railtie"
# insert:
# config.middleware.use ActionDispatch::Cookies
# config.middleware.use ActionDispatch::Session::CookieStore
# config.middleware.use ActionDispatch::Flash


cat <<EOF > config/initializers/assets.rb
# apps/ehr-api/config/initializers/assets.rb
Rails.application.config.assets.precompile += %w(
  active_admin.js
  active_admin.css
)
EOF

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

# TODO: In apps/ehr-api/config/initializers/active_admin.rb
# replace config.site_title = "Ehr Api"
# with config.site_title = "EHR Portal Admin"

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


cat <<EOF >> config/initializers/assets.rb
# apps/ehr-api/config/initializers/assets.rb
# frozen_string_literal: true
Rails.application.config.assets.precompile += %w(
  active_admin.js
  active_admin.css
)
EOF

# config/initializers/dartsass.rb
# frozen_string_literal: true

# TODO: DART SASS initializer
# Rails.application.config.dartsass.builds = {
#   "application.scss"    => "application.css",
#   "active_admin.scss"   => "active_admin.css"
# }

# app/views/layouts/active_admin.html.erb
# <%= stylesheet_link_tag "active_admin", "data-turbo-track": "reload" %>
# <%= javascript_include_tag "active_admin", "data-turbo-track": "reload" %>

# TODO: add ActiveAdmin dashboard request specs

info "Adding Devise RBS shim..."
cat << 'EOF' > sig/shims/devise.rbs
# sig/shims/devise.rbs
# Minimal stubs for Devise authentication helpers.
# Remove once devise ships official RBS definitions.

module Devise
  module Models
    module DatabaseAuthenticatable
    end

    module Registerable
    end

    module Recoverable
    end

    module Rememberable
    end

    module Validatable
    end
  end
end

# Devise adds the `devise` class macro to ActiveRecord models.
# Declared here so all_error doesn't flag `devise :database_authenticatable, ...`
# as a missing method on model singletons.
class ActiveRecord::Base
  def self.devise: (*::Symbol, **untyped) -> void
end
EOF
