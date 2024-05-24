class GenresController < ApplicationController
  def index
    @genres = Genre.all
    used_tmdb_ids = []

    @cover_cards = @genres.map do |genre|
      top_title = genre.titles.where("imdb_votes > 0").where.not(tmdb_id: used_tmdb_ids).order(imdb_votes: :desc).first
      next unless top_title

      used_tmdb_ids << top_title.tmdb_id
      backdrop_url = fetch_backdrop(top_title.tmdb_id, top_title.media_type)
      { genre: genre, backdrop_url: backdrop_url }
    end.compact
  end

  def show
    @genre = Genre.find_by(tmdb_id: params[:id])
    @db_movies = @genre.titles.where(media_type: 'movie').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:movie_page]).per(12) || []
    @db_tv_shows = @genre.titles.where(media_type: 'tv').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:tv_page]).per(12) || []
    existing_tmdb_ids = @db_movies.pluck(:tmdb_id) + @db_tv_shows.pluck(:tmdb_id)

    # Fetch and save additional titles
    fetch_and_save_additional_titles(@genre.tmdb_id, existing_tmdb_ids, 'movie', 3)
    fetch_and_save_additional_titles(@genre.tmdb_id, existing_tmdb_ids, 'tv', 3)

    # Refresh the lists to include the newly added titles and sort by IMDb votes
    @db_movies = @genre.titles.where(media_type: 'movie').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:movie_page]).per(12) || []
    @db_tv_shows = @genre.titles.where(media_type: 'tv').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:tv_page]).per(12) || []
  end

  private

  def fetch_backdrop(tmdb_id, media_type)
    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    backdrops = tmdb_api.fetch_title_backdrops(tmdb_id, media_type)
    backdrops.first # Use the first backdrop for simplicity
  end

  def fetch_and_save_additional_titles(genre_tmdb_id, existing_tmdb_ids, media_type, count)
    # Fetch additional titles from TMDB API and save to the database
    # This is a placeholder for the actual implementation
  end
end
