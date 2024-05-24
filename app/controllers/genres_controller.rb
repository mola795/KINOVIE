class GenresController < ApplicationController
  def index
    @genres = Genre.all
  end

  def show
    @genre = Genre.find_by(tmdb_id: params[:id])
    @db_movies = @genre.titles.where(media_type: 'movie').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:movie_page]).per(18)
    @db_tv_shows = @genre.titles.where(media_type: 'tv').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:tv_page]).per(18)
    existing_tmdb_ids = @db_movies.pluck(:tmdb_id) + @db_tv_shows.pluck(:tmdb_id)

    # Fetch and save additional titles
    fetch_and_save_additional_titles(@genre.tmdb_id, existing_tmdb_ids, 'movie', 3)
    fetch_and_save_additional_titles(@genre.tmdb_id, existing_tmdb_ids, 'tv', 3)

    # Refresh the lists to include the newly added titles and sort by IMDb votes
    @db_movies = @genre.titles.where(media_type: 'movie').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:movie_page]).per(12)
    @db_tv_shows = @genre.titles.where(media_type: 'tv').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:tv_page]).per(12)
  end
end
