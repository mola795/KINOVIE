require 'httparty'

class TmdbApi
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_movie_details(movie_id)
    self.class.get("/movie/#{movie_id}", query: { api_key: @api_key, language: 'en-US' }).parsed_response
  end

  def fetch_movie_cast(movie_id)
    self.class.get("/movie/#{movie_id}/credits", query: { api_key: @api_key, language: 'en-US' })['cast']
  end
end
