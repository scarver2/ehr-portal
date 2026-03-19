# apps/ehr-api/config/initializers/cors.rb
# frozen_string_literal: true

ALLOWED_ORIGINS = [
  "https://ehr.stancarver.com",
  ("http://localhost:3001" if Rails.env.development?)
].compact.freeze

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ALLOWED_ORIGINS)

    resource "*",
      headers: :any,
      methods: [:get, :post, :patch, :put, :delete, :options, :head],
      credentials: true
  end
end
