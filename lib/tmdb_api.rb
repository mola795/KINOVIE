class TmdbApi
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_title_backdrops(title_id, media_type)
    media_type_mapped = map_media_type(media_type)
    response = self.class.get("/#{media_type_mapped}/#{title_id}/images", query: { api_key: @api_key }).parsed_response
    response['backdrops'].sort_by { |backdrop| -backdrop['vote_count'] }.first(3).map { |backdrop| "https://image.tmdb.org/t/p/original#{backdrop['file_path']}" }
  rescue => e
    puts "Error fetching title backdrops: #{e.message}"
    []
  end

  def fetch_top_title_backdrop(title_id, media_type)
    media_type_mapped = map_media_type(media_type)
    response = self.class.get("/#{media_type_mapped}/#{title_id}/images", query: { api_key: @api_key }).parsed_response
    backdrop = response['backdrops'].sort_by { |backdrop| -backdrop['vote_count'] }.first
    "https://image.tmdb.org/t/p/original#{backdrop['file_path']}" if backdrop
  rescue => e
    Rails.logger.error "Error fetching top title backdrop: #{e.message}"
    nil
  end

  def fetch_top_rated_movies(page = 1)
    self.class.get("/movie/top_rated", query: { api_key: @api_key, language: 'en-US', page: page }).parsed_response['results']
  rescue => e
    puts "Error fetching top-rated movies: #{e.message}"
    []
  end

  def fetch_popular_movies
    self.class.get("/movie/popular", query: { api_key: @api_key, language: 'en-US' }).parsed_response['results']
  rescue => e
    puts "Error fetching popular movies: #{e.message}"
    []
  end

  def fetch_popular_tv_shows
    self.class.get("/tv/popular", query: { api_key: @api_key, language: 'en-US' }).parsed_response['results']
  rescue => e
    puts "Error fetching popular TV shows: #{e.message}"
    []
  end

  def fetch_title_details(title_id, media_type)
    media_type_mapped = map_media_type(media_type)
    self.class.get("/#{media_type_mapped}/#{title_id}", query: { api_key: @api_key, language: 'en-US' }).parsed_response
  rescue => e
    puts "Error fetching title details: #{e.message}"
    {}
  end

  def fetch_movie_cast(movie_id)
    self.class.get("/movie/#{movie_id}/credits", query: { api_key: @api_key, language: 'en-US' })['cast']
  rescue => e
    puts "Error fetching movie cast: #{e.message}"
    []
  end

  def fetch_tv_cast(tv_id)
    self.class.get("/tv/#{tv_id}/credits", query: { api_key: @api_key, language: 'en-US' })['cast']
  rescue => e
    puts "Error fetching TV show cast: #{e.message}"
    []
  end

  def search_movies(query, year, limit = 5)
    movies = self.class.get("/search/movie", query: { api_key: @api_key, query: query, year: year, language: 'en-US' }).parsed_response['results']
    handle_response(movies).first(limit)
  rescue => e
    puts "Error searching movies: #{e.message}"
    []
  end

  def search_tv_shows(query, year, limit = 5)
    tv_shows = self.class.get("/search/tv", query: { api_key: @api_key, query: query, first_air_date_year: year, language: 'en-US' }).parsed_response['results']
    handle_response(tv_shows).first(limit)
  rescue => e
    puts "Error searching TV shows: #{e.message}"
    []
  end

  def fetch_credits(title_id, media_type)
    media_type_mapped = map_media_type(media_type)
    self.class.get("/#{media_type_mapped}/#{title_id}/credits", query: { api_key: @api_key, language: 'en-US' }).parsed_response
  rescue => e
    puts "Error fetching credits: #{e.message}"
    {}
  end

  def search_movies_and_tv_shows(query, limit = 5)
    movies = self.class.get("/search/movie", query: { api_key: @api_key, query: query, language: 'en-US' }).parsed_response['results']
    tv_shows = self.class.get("/search/tv", query: { api_key: @api_key, query: query, language: 'en-US' }).parsed_response['results']

    movies.each { |movie| movie['media_type'] = 'movie' }
    tv_shows.each { |tv| tv['media_type'] = 'tv' }

    combined_results = (movies + tv_shows).sort_by { |result| result['popularity'] }.reverse.first(limit)
    handle_response(combined_results)
  rescue => e
    puts "Error searching movies and TV shows: #{e.message}"
    []
  end

  private

  def handle_response(response)
    if response
      response
    else
      puts "Error fetching data from TMDb: #{response.message}"
      {}
    end
  rescue => e
    puts "Error parsing response from TMDb: #{e.message}"
    {}
  end

  def map_media_type(media_type)
    case media_type
    when 'series'
      'tv'
    else
      media_type
    end
  end
end
