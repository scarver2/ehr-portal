Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
  get "/up", to: proc { [200, {}, ["ok"]] }
  get "/api/up", to: proc { [200, {}, ["ok"]] }

  post "/graphql", to: "graphql#execute"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html


  # Defines the root path route ("/")
  # root "posts#index"
end
