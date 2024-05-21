Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: "pages#home"

  resources :genres, only: %i[index show]
  resources :lists, only: %i[show new create index edit update destroy]
  resources :titles, only: %i[show] do
    resources :reviews, only: %i[index new create]
  end
  resources :list_items, only: %i[new create destroy]
  resources :users, only: %i[show new create]

  get '/profile', to: 'pages#profile', as: :profile
  get '/users/:username', to: 'users#show', as: :username

  resources :people, only: %i[show]
  resources :services, only: %i[index show]
  resources :follows, only: %i[create destroy]

  get "up" => "rails/health#show", as: :rails_health_check

  get '/popular', to: 'titles#popular', as: :popular_titles

  # Defines the root path route ("/")
  # root "posts#index"
end
