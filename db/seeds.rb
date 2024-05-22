require 'httparty'
require 'rest-client'
require_relative '../lib/tmdb_api'
require_relative '../lib/omdb_api'

puts "Cleaning the DB..."
Streaming.destroy_all
Title.destroy_all
Service.destroy_all

class WatchModeApi
  include HTTParty
  base_uri 'https://api.watchmode.com/v1'

  def initialize(watchmode_api_key)
    @watchmode_api_key = watchmode_api_key
  end

  def get_sources(regions)
    self.class.get("/sources/?apiKey=#{@watchmode_api_key}&regions=#{regions}").parsed_response
  end

  def get_title_details(title_id, regions)
    self.class.get("/title/#{title_id}/sources/?apiKey=#{@watchmode_api_key}&regions=#{regions}").parsed_response
  end
end

def extract_years(date)
  return [nil, nil] unless date

  if date.include?('–')
    start_year, end_year = date.split('–').map(&:strip).map(&:to_i)
    end_year = nil if end_year == 0
    [start_year, end_year]
  else
    [date.split('-').first.to_i, nil]
  end
end

def map_media_type(media_type)
  case media_type
  when 'movie'
    'movie'
  when 'series'
    'tv'
  when 'episode'
    'episode'
  else
    media_type
  end
end

def seed_services(watchmode_api)
  services = watchmode_api.get_sources('US')
  services.reject { |service| service['type'] == 'tve' }.each do |service|
    Service.create!(
      name: service['name'],
      watchmode_id: service['id'],
      logo_url: service['logo_100px']
    )
    puts "Created service: #{service['name']}"
  end
end

def seed_popular_titles(tmdb_api, omdb_api, watchmode_api)
  movies = tmdb_api.fetch_popular_movies.first(20)
  tv_shows = tmdb_api.fetch_popular_tv_shows.first(20)
  titles = movies + tv_shows

  titles.each_with_index do |title, index|
    begin
      media_type = title['media_type'] || (title['first_air_date'] ? 'tv' : 'movie')
      next if media_type == 'episode'

      puts "Processing title #{index + 1}/#{titles.size}: #{title['name'] || title['title']} (#{media_type})"

      tmdb_details = tmdb_api.fetch_title_details(title['id'], media_type)
      start_year, end_year = extract_years(tmdb_details['release_date'] || tmdb_details['first_air_date'])

      if media_type == 'tv' && tmdb_details['last_air_date']
        end_year = tmdb_details['last_air_date'].split('-').first.to_i
      end

      imdb_id = tmdb_details['imdb_id']
      if imdb_id.nil? || imdb_id.empty?
        imdb_id = omdb_api.fetch_imdb_id(title['name'] || title['title'], start_year)
      end

      imdb_rating = nil
      imdb_votes = 0
      omdb_media_type = nil
      if imdb_id
        omdb_details = omdb_api.fetch_movie_details(imdb_id)
        imdb_rating = omdb_details['imdbRating']
        imdb_votes = omdb_details['imdbVotes'].gsub(',', '').to_i if omdb_details['imdbVotes']
        omdb_media_type = omdb_details['Type']

        if media_type == 'tv' && omdb_details['Year'].include?('–')
          start_year, end_year = extract_years(omdb_details['Year'])
        end
      end

      media_type = map_media_type(omdb_media_type) if omdb_media_type && omdb_media_type != media_type

      title_record = Title.create!(
        name: title['name'] || title['title'],
        media_type: media_type,
        start_year: start_year,
        end_year: end_year,
        tmdb_id: title['id'],
        imdb_id: imdb_id,
        poster_url: "https://image.tmdb.org/t/p/w500#{title['poster_path']}",
        imdb_rating: imdb_rating,
        imdb_votes: imdb_votes
      )

      puts "Created title: #{title['name'] || title['title']} (TMDb ID: #{title['id']}, IMDb ID: #{imdb_id}, IMDb Rating: #{imdb_rating}, IMDb Votes: #{imdb_votes})"

      # Fetch and link streaming sources
      title_id = "#{media_type}-#{title['id']}"
      streaming_sources = watchmode_api.get_title_details(title_id, 'US')
      puts "Fetched streaming sources for title #{title_id}."

      streaming_sources.select { |streaming_src| streaming_src['format'] == 'HD' }.each do |streaming_src|
        service = Service.find_or_create_by(name: streaming_src['name'])
        Streaming.create!(
          url: streaming_src['web_url'],
          service: service,
          title: title_record
        )
        puts "Linked service #{service.name} to title #{title_record.name} with URL"
      end

      if media_type == 'movie'
        puts "Added movie with start year: #{start_year}"
      else
        if end_year.nil?
          puts "Added TV show with start year: #{start_year} and ongoing"
        else
          puts "Added TV show with start year: #{start_year} and end year: #{end_year}"
        end
      end

    rescue => e
      puts "Error processing title #{title['name'] || title['title']}: #{e.message}"
    end
  end
end

puts "Seeding services from WatchMode..."
watchmode_api_key = ENV['WATCHMODE_API_KEY']
watchmode_api = WatchModeApi.new(watchmode_api_key)
seed_services(watchmode_api)

puts "Seeding popular movies and TV shows from TMDb..."
tmdb_api_key = ENV['TMDB_API_KEY']
omdb_api_key = ENV['OMDB_API_KEY']
tmdb_api = TmdbApi.new(tmdb_api_key)
omdb_api = OmdbApi.new(omdb_api_key)
seed_popular_titles(tmdb_api, omdb_api, watchmode_api)

puts "Seeding completed."
