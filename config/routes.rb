Rails.application.routes.draw do
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
  resources :users, only: %i(index new create show)

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
