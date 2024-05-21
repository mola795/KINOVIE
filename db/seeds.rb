require 'httparty'

class TMDBApi
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_popular_movies
    self.class.get("/movie/popular", query: { api_key: @api_key, language: 'en-US' })
  end
end

def seed_popular_movies(api)
  movies = api.fetch_popular_movies['results']
  movies.each do |movie|
    Title.create(
      name: movie['title'],
      media_type: 'movie',
      release_date: movie['release_date'],
      tmdb_id: movie['id'],
      poster_url: "https://image.tmdb.org/t/p/w500#{movie['poster_path']}"
    )
  end
end

puts "Seeding popular movies from TMDb..."
api_key = ENV['TMDB_API_KEY']
tmdb_api = TMDBApi.new(api_key)
seed_popular_movies(tmdb_api)
puts "Seeding completed."
