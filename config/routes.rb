Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: "pages#home"

  resources :genres, only: %i[index show]
  resources :lists, only: %i[show new create index edit update destroy]
  resources :titles, only: %i[index show new create] do
    resources :reviews, only: %i[index new create]
    resources :list_items, only: %i[create] do
      collection do
        post 'add_to_watchlist'
      end
    end
  end
  resources :list_items, only: %i[new create destroy]
  resources :users, only: %i[show]


  get '/profile', to: 'pages#profile', as: :profile
  get '/users/:username', to: 'users#show', as: :username
  get '/users/:id/lists', to: 'users#lists', as: 'user_lists'

  resources :people, only: %i[show]
  resources :services, only: %i[index show]
  resources :follows, only: %i[create destroy]

  get "up" => "rails/health#show", as: :rails_health_check

  get '/popular', to: 'titles#popular', as: :popular_titles
  get 'search', to: 'search#index', as: 'search'
  get 'movies', to: 'titles#movies', as: 'movies'
  get 'tv_shows', to: 'titles#tv_shows', as: 'tv_shows'

  # Defines the root path route ("/")
  # root "posts#index"
end
