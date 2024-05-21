# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    @query = params[:query]
    @titles = Title.search_by_name(@query)

    if @titles.empty?
      tmdb_api = TmdbApi.new(ENV['TMDB_API_KEY'])
      tmdb_results = tmdb_api.search_movies(@query, 5) # limit to 5 results

      @titles = tmdb_results.map do |tmdb_movie|
        Title.find_or_create_by(tmdb_id: tmdb_movie['id']) do |t|
          t.name = tmdb_movie['title']
          t.media_type = 'movie'
          t.release_date = tmdb_movie['release_date']
          t.poster_url = "https://image.tmdb.org/t/p/w500/#{tmdb_movie['poster_path']}"
          t.imdb_id = fetch_imdb_id(tmdb_movie['id'], tmdb_api)
        end
      end
    end
  end

  private

  def fetch_imdb_id(tmdb_id, tmdb_api)
    movie_details = tmdb_api.fetch_movie_details(tmdb_id)
    movie_details['imdb_id']
  end
end
