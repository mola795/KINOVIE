Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: "pages#home"

  resources :genres, only: %i[index show]
  resources :lists, only: %i[show new create index edit update destroy] do
    resources :list_items, only: %i[create destroy update]
    resources :genre_connections, only: %i[create destroy update]
  end
  resources :titles, only: %i[index show new create] do
    resources :reviews, only: %i[create update destroy]
    resources :list_items, only: %i[create] do
      collection do
        post 'add_to_watchlist'
        post 'add_to_ratings_list'
      end
    end
  end
  resources :list_items, only: %i[new create destroy]

  get '/users/:username/followers', to: 'pages#followers', as: :followers
  get '/users/:username/following', to: 'users#following', as: :following
  get '/users/:username/follow', to: 'users#follow', as: :follow_user
  get '/users/:username/unfollow', to: 'users#unfollow', as: :unfollow_user
  get '/users/:username', to: 'users#show', as: :user
  get '/users/:username/lists', to: 'users#lists', as: 'user_lists'

  post 'add_to_watchlist', to: 'list_items#add_to_watchlist', as: :add_to_watchlist

  # Likes
  get '/reviews/:review/like_review', to: 'reviews#like_review', as: :like_review
  get '/reviews/:review/unlike_review', to: 'reviews#unlike_review', as: :unlike_review

  resources :people, only: %i[show]
  resources :services, only: %i[index show new create]
  resources :comments, only: [:create]

  get "up" => "rails/health#show", as: :rails_health_check

  get '/popular', to: 'titles#popular', as: :popular_titles
  get 'search', to: 'search#index', as: 'search'
  get 'movies', to: 'titles#movies', as: 'movies'
  get 'tv_shows', to: 'titles#tv_shows', as: 'tv_shows'
  get '/activity', to: 'pages#activity', as: :activity
end
