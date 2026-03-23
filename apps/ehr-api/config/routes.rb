# apps/ehr-api/config/routes.rb
# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq Web UI — admin only
  authenticate(:admin_user) do
    mount PgHero::Engine => '/pghero'
    mount Sidekiq::Web => '/sidekiq'
  end

  # ActionCable WebSocket endpoint
  mount ActionCable.server => '/cable'

  # ActiveAdmin devise authentication (for /admin/login, /admin/logout, etc.)
  devise_for :admin_users, ActiveAdmin::Devise.config

  # Admin panel route
  ActiveAdmin.routes(self)

  root to: redirect('/admin')

  get '/healthz', to: proc { [200, {}, ['ok']] }
  get '/up',      to: proc { [200, {}, ['ok']] }
  get '/api/up',  to: proc { [200, {}, ['ok']] }

  post '/graphql', to: 'graphql#execute'

  namespace :api do
    resources :insurance_verifications, only: %i[create show index]
  end

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  # API JWT authentication — custom Rodauth controllers
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post :login, to: 'sessions#create'
        delete :logout, to: 'sessions#destroy'
      end
    end
  end
end
