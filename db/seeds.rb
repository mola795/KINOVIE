require 'httparty'
require 'faker'

puts "Cleaning the DB..."
# Destroy all records for seeded objects
# Object.destroy_all

class WatchModeApi
  include HTTParty
  base_uri 'https://api.watchmode.com/v1'

  def get_sources(regions)
    # Where regions is a comma separated string of 2 character country codes
    # available from the watchmode /regions endpoint
    api_key = 'Wa0xNagkzZLawLxWCcarWIGDwFW6bILgqpJrokZf'
    self.class.get("/sources/?apiKey=#{api_key}&regions=#{regions}")
  end

  # def get_source_details(source_id)
  #   api_key = 'Wa0xNagkzZLawLxWCcarWIGDwFW6bILgqpJrokZf'
  #   sources = self.class.get("/sources/?apiKey=#{api_key}&regions=#{regions}")
  # end

  def get_title_details(title_id, regions)
    # Where regions is a comma separated string of 2 character country codes
    # available from the watchmode /regions endpoint
    api_key = 'Wa0xNagkzZLawLxWCcarWIGDwFW6bILgqpJrokZf'
    self.class.get("/title/#{title_id}/sources/?apiKey=#{api_key}&regions=#{regions}")
  end
end

watchmode_api = WatchModeApi.new

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
    title = Title.create(
      name: movie['title'],
      media_type: 'movie',
      release_date: movie['release_date'],
      tmdb_id: movie['id'],
      poster_url: "https://image.tmdb.org/t/p/w500#{movie['poster_path']}"
    )
    tmdb_id = title.tmdb_id

    streaming_sources = watchmode_api.get_title_details(tmdb_id, '')
    streaming_sources.select{|streaming_src| streaming_src["format"] == 'HD'}.each do |streaming_src|
      service = Service.where(name: streaming_src['name']).first
      streaming = Streaming.new(
        url: streaming_src['web_url'],
        # service_id: service.id
      )
      streaming.service = service
      streaming.title = title
      streaming.save
    end
  end
end

# Seed all available sources
services = watchmode_api.get_sources('')
services.each do |service|
  Service.create(
    name: service.name,
    watchmode_id: service.id
  )
end

puts "Seeding popular movies from TMDb..."
api_key = ENV['TMDB_API_KEY']
tmdb_api = TMDBApi.new(api_key)
seed_popular_movies(tmdb_api)
puts "Seeding completed."
