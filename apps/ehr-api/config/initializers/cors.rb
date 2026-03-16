# apps/ehr-api/config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://ehr.stancarver.com"

    resource "*",
      headers: :any,
      methods: [:get, :post, :options],
      credentials: false
  end
end
