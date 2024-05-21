class TmdbService
  API_KEY = ENV['TMDB_API_KEY']
  BASE_URL = 'https://api.themoviedb.org/3'

  def self.search_movie(query, limit = 20)
    response = RestClient.get("#{BASE_URL}/search/movie", params: { query: query, api_key: API_KEY })
    results = JSON.parse(response.body)['results']
    results.first(limit) # limit the number of results to the specified limit
  end

  def self.fetch_movie_details(tmdb_id)
    response = RestClient.get("#{BASE_URL}/movie/#{tmdb_id}", params: { api_key: API_KEY })
    JSON.parse(response.body)
  end
end
