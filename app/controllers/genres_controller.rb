class GenresController < ApplicationController
  def index
    @genres = Genre.all
  end

  def show
    @genre = Genre.find_by(tmdb_id: params[:id])
    @db_movies = @genre.titles.where(media_type: 'movie')
    @db_tv_shows = @genre.titles.where(media_type: 'tv')
    existing_tmdb_ids = @db_movies.pluck(:tmdb_id) + @db_tv_shows.pluck(:tmdb_id)
    @api_movies = fetch_additional_titles(@genre.tmdb_id, existing_tmdb_ids, 'movie', 12)
    @api_tv_shows = fetch_additional_titles(@genre.tmdb_id, existing_tmdb_ids, 'tv', 12)
  end

  private

  def fetch_titles_by_genre(genre_id, media_type, page = 1)
    tmdb_api_key = ENV['TMDB_API_KEY']
    url = URI("https://api.themoviedb.org/3/discover/#{media_type}?api_key=#{tmdb_api_key}&with_genres=#{genre_id}&language=en-US&page=#{page}")
    response = Net::HTTP.get(url)
    JSON.parse(response)["results"]
  rescue => e
    Rails.logger.error "Error fetching #{media_type} titles for genre #{genre_id}: #{e.message}"
    []
  end

  def fetch_additional_titles(genre_id, existing_tmdb_ids, media_type, limit)
    additional_titles = []
    page = 1
    while additional_titles.size < limit
      titles = fetch_titles_by_genre(genre_id, media_type, page)
      titles.reject! { |title| existing_tmdb_ids.include?(title['id']) }
      additional_titles += titles
      break if titles.empty? # Stop if no more titles are returned
      page += 1
    end
    additional_titles.first(limit)
  end
end
