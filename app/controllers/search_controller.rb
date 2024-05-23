class SearchController < ApplicationController
  def index
    @query = params[:query]

    if @query.present?
      tmdb_api = TmdbApi.new(ENV['TMDB_API_KEY'])
      tmdb_results = tmdb_api.search_movies_and_tv_shows(@query, 10)

      @titles = tmdb_results.map do |tmdb_title|
        media_type = tmdb_title['media_type']
        tmdb_id = tmdb_title['id']
        title = create_or_find_title(tmdb_id, media_type)

        {
          id: title.id,
          name: title.name,
          media_type: title.media_type,
          start_year: title.start_year,
          end_year: title.end_year,
          poster_path: title.poster_url,
          imdb_id: title.imdb_id,
          imdb_rating: title.imdb_rating,
          imdb_votes: title.imdb_votes
        }
      end
    else
      @titles = []
    end
  end
end
