Rails.application.routes.draw do
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :products
  get "demo_partials/edit"
  get "demo_partials/new"
  get "static_pages/contact"
  get "static_pages/help"
  get "static_pages/home"

  root "microposts#index"

  resources :microposts, only: [:index]

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  resources :users, only: %i(index new create show edit update destroy)
  resources :password_resets, only: %i(new edit create update)
  resources :account_activations, only: :edit

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
