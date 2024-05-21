Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :genres, only: %i[index show]
  resources :lists, only: %i[show new create]
  resources :titles, only: %i[show]
  resources :list_items, only: %i[new create destroy]

  get '/profile', to: 'pages#profile', as: :profile
  get '/users/:username', to: 'pages#username', as: :username
  get 'search', to: 'search#index', as: 'search'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
