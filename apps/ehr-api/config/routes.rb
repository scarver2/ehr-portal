Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "/healthz", to: proc { [200, {}, ["ok"]] }
  get "/up", to: proc { [200, {}, ["ok"]] }
  get "/api/up", to: proc { [200, {}, ["ok"]] }

  post "/graphql", to: "graphql#execute"
  devise_for :users
end
