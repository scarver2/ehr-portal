# apps/ehr-api/config/initializers/assets.rb
# frozen_string_literal: true

Rails.application.config.assets.precompile += %w[
  active_admin.js
  active_admin.css
]
