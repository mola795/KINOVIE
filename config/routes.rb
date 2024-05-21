Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :genres, only: %i[index show]
  resources :lists, only: %i[show new create index edit update]
  resources :titles, only: %i[show] do
    resources :reviews, only: %i[index new create]
  end
  resources :list_items, only: %i[new create destroy]
  resources :users, only: %i[show new create]

  get '/profile', to: 'pages#profile', as: :profile
  get '/users/:username', to: 'users#show', as: :username

  resources :people, only: %i[show]
  resources :services, only: %i[index show]

  resources :comments, only: %i[new create]
  resources :follows, only: %i[create]

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
