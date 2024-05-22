require 'httparty'
require 'faker'

puts "Cleaning the DB..."
# Destroy all records for seeded objects
Streaming.destroy_all
Title.destroy_all
Service.destroy_all

# Structure for utilization of HTTParty: https://github.com/jnunemaker/httparty
class WatchModeApi
  include HTTParty
  base_uri 'https://api.watchmode.com/v1'

  def initialize(watchmode_api_key)
    @watchmode_api_key = watchmode_api_key
  end

  # Method to get all available sources (Netflix, AppleTV, Prime, etc.).
  # Can be filtered by region(s), given a one or more 2-char country code ('US,CA,JP')
  def get_sources(regions)
    self.class.get("/sources/?apiKey=#{@watchmode_api_key}&regions=#{regions}")
  end

  # Method to get the details of all available sources for a given title
  # 'Where can I watch Fallout?'
  def get_title_details(title_id, regions)
    self.class.get("/title/#{title_id}/sources/?apiKey=#{@watchmode_api_key}&regions=#{regions}")
  end
end

class TMDBApi
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

  def initialize(tmdb_api_key)
    @tmdb_api_key = tmdb_api_key
  end

  def fetch_popular_movies
    self.class.get("/movie/popular", query: { api_key: @tmdb_api_key, language: 'en-US' })
  end
end

def seed_popular_movies(tmdb_api)
  # Return a list of popular movies
  movies = tmdb_api.fetch_popular_movies['results']
  # For each movie returned, create a record with the extracted details
  movies.each do |movie|
    title = Title.create(
      name: movie['title'],
      media_type: 'movie',
      release_date: movie['release_date'],
      tmdb_id: movie['id'],
      poster_url: "https://image.tmdb.org/t/p/w500#{movie['poster_path']}"
    )
    # For each title, assign its tmdb_id to use in the Watchmode Request
    tmdb_id = title.tmdb_id
    # tmdb_id = `#{title.media_type}-#{title.tmdb_id}`
    title_id = title.media_type + '-' + tmdb_id.to_s
    # Create a new instance of the Watchmode API request
    watchmode_api_key = ENV['WATCHMODE_API_KEY']
    watchmode_api = WatchModeApi.new(watchmode_api_key)
    # Get all streaming sources available for the current title in the US
    streaming_sources = watchmode_api.get_title_details(title_id, 'US')
    # Selecting only the HD sources, find the corresponding service from our existing
    # DB of streaming services based on name
    streaming_sources.select { |streaming_src| streaming_src['format'] == 'HD' }.each do |streaming_src|
      service = Service.where(name: streaming_src['name']).first
      # Create a new streaming record, pulling url from the current streaming source
      streaming = Streaming.new(
        url: streaming_src['web_url']
      )
      # When assigning reference, do it outside of record creation, then save
      # The below ties our newly created streaming record to its associated
      # service & title
      streaming.service = service
      streaming.title = title
      streaming.save
    end
  end
end

watchmode_api_key = ENV['WATCHMODE_API_KEY']
watchmode_api = WatchModeApi.new(watchmode_api_key)
# Seed all available sources (within the US for now)
services = watchmode_api.get_sources('US')
services.reject { |service| service['type'] == 'tve' }.each do |service|
  Service.create(
    name: service['name'],
    watchmode_id: service['id'],
    logo_url: service['logo_100px']
  )
end

puts "Seeding popular movies from TMDb..."
tmdb_api_key = ENV['TMDB_API_KEY']
tmdb_api = TMDBApi.new(tmdb_api_key)
seed_popular_movies(tmdb_api)
puts "Seeding completed."
