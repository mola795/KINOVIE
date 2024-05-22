require 'httparty'

class OmdbApi
  include HTTParty
  base_uri 'http://www.omdbapi.com/'

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_movie_details(imdb_id)
    self.class.get("/", query: { apikey: @api_key, i: imdb_id }).parsed_response
  rescue => e
    puts "Error fetching movie details from OMDb: #{e.message}"
    {}
  end

  def fetch_imdb_id(title, year)
    response = self.class.get("/", query: { apikey: @api_key, t: title, y: year }).parsed_response
    response['imdbID']
  rescue => e
    puts "Error fetching IMDb ID from OMDb: #{e.message}"
    nil
  end
end
