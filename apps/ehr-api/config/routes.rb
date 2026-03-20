# apps/ehr-api/config/routes.rb
# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # Sidekiq Web UI — admin role only
  authenticate(:user, ->(u) { u.admin? }) do
    mount Sidekiq::Web => "/sidekiq"
    mount PgHero::Engine => "/pghero"
  end

  # ActionCable WebSocket endpoint
  mount ActionCable.server => "/cable"

  # ActiveAdmin devise authentication (for /admin/login, /admin/logout, etc.)
  devise_for :users, ActiveAdmin::Devise.config

  # Admin panel route
  ActiveAdmin.routes(self)

  root to: redirect("/admin")

  get "/healthz", to: proc { [200, {}, ["ok"]] }
  get "/up",      to: proc { [200, {}, ["ok"]] }
  get "/api/up",  to: proc { [200, {}, ["ok"]] }

  post "/graphql", to: "graphql#execute"

  namespace :api do
    resources :insurance_verifications, only: %i[create show index]
  end

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  # API JWT authentication — scoped to :api namespace with custom route helpers
  scope path: 'api/v1', as: :api_v1 do
    devise_for :users,
      path: 'auth',
      path_names: { sign_in: 'login', sign_out: 'logout' },
      controllers: { sessions: 'api/v1/auth/sessions' },
      skip: %i[registrations confirmations passwords unlocks omniauth_callbacks]
  end
end
