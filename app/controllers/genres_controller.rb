class GenresController < ApplicationController
  def index
    @genres = Genre.all
  end

  def show
    @genre = Genre.find_by(tmdb_id: params[:id])

    if @genre.nil?
      redirect_to genres_path, alert: "Genre not found"
      return
    end

    @db_movies = @genre.titles.where(media_type: 'movie').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:movie_page]).per(12) || []
    @db_tv_shows = @genre.titles.where(media_type: 'tv').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:tv_page]).per(12) || []
    @lists = @genre.lists.distinct
    @cover_url = params[:cover_url] || @genre.cover_url

    unless params[:skip_update]
      check_and_update_genre_cover_url
    end
  end

  private

  def fetch_backdrops(tmdb_id, media_type)
    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    tmdb_api.fetch_title_backdrops(tmdb_id, media_type)
  end

  def check_and_update_genre_cover_url
    if @genre.cover_url.blank? || genre_cover_title_imdb_votes_changed?
      top_title = find_new_top_title_for_genre
      if top_title
        tmdb_api = TmdbApi.new(ENV['TMDB_API_KEY'])
        cover_url = tmdb_api.fetch_top_title_backdrop(top_title.tmdb_id, top_title.media_type)
        if cover_url
          @genre.update(cover_url: cover_url)
        else
          Rails.logger.error "Failed to fetch cover_url for genre #{@genre.name}"
        end
      else
        Rails.logger.error "No top title found for genre #{@genre.name}"
      end
    end
  end

  def find_new_top_title_for_genre
    @genre.titles.where(media_type: 'movie').where("imdb_votes >= 25000").order(imdb_votes: :desc).find do |title|
      title_genres = title.genres.pluck(:name)
      # Überspringe Titel, die das Genre "Animation" enthalten, wenn das aktuelle Genre nicht "Animation" ist
      next if title_genres.include?('Animation') && @genre.name != 'Animation'
      # Überspringe Titel, die das Genre "Animation" nicht enthalten, wenn das aktuelle Genre "Animation" ist
      next if !title_genres.include?('Animation') && @genre.name == 'Animation'

      !Genre.exists?(cover_url: fetch_backdrop_url(title.tmdb_id, title.media_type))
    end
  end

  def fetch_backdrop_url(tmdb_id, media_type)
    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    tmdb_api.fetch_top_title_backdrop(tmdb_id, media_type)
  end

  def genre_cover_title_imdb_votes_changed?
    top_title = @genre.titles.where(media_type: 'movie').where("imdb_votes >= 25000").order(imdb_votes: :desc).first
    cover_url_top_title = Genre.where(cover_url: @genre.cover_url).first
    return false unless top_title && cover_url_top_title

    top_title.id != cover_url_top_title.id
  end
end
