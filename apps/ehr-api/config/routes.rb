# apps/ehr-api/config/routes.rb
# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "/healthz", to: proc { [200, {}, ["ok"]] }
  get "/up", to: proc { [200, {}, ["ok"]] }
  get "/api/up", to: proc { [200, {}, ["ok"]] }

  post "/graphql", to: "graphql#execute"

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  devise_for :users
end
