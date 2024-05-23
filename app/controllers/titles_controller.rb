# app/controllers/titles_controller.rb

class TitlesController < ApplicationController
  def index
    @titles = Title.all
  end

  def popular
    @titles = Title.where(media_type: ['movie', 'tv']).order('created_at DESC').limit(100)
    @total_titles_count = Title.count
  end

  def show
    @title = Title.find(params[:id])
    @list_item = ListItem.new
    fetch_and_display_title_details
  rescue ActiveRecord::RecordNotFound => e
    logger.error "Title not found: #{e.message}"
    redirect_to titles_path, alert: "Title not found."
  rescue StandardError => e
    logger.error "Error fetching title details: #{e.message}"
    redirect_to titles_path, alert: "An error occurred while fetching title details."
  end

  def new
    @title = Title.new
  end

  def create
    tmdb_id = params[:title][:tmdb_id]
    media_type = params[:title][:media_type]

    title = create_or_find_title(tmdb_id, media_type)
    if title
      redirect_to title
    else
      redirect_to new_title_path, alert: 'Title not found in TMDb.'
    end
  end

  private

  def fetch_and_display_title_details
    tmdb_api_key = ENV['TMDB_API_KEY']
    omdb_api_key = ENV['OMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    omdb_api = OmdbApi.new(omdb_api_key)

    media_type = map_media_type(@title.media_type)
    logger.debug "Fetching TMDb details for title ID: #{@title.tmdb_id}, Media Type: #{media_type}"
    @movie_details = tmdb_api.fetch_title_details(@title.tmdb_id, media_type)

    if @movie_details.blank?
      logger.error "Title details not found in TMDb response"
      raise ActiveRecord::RecordNotFound, "Title details not found in TMDb response"
    end

    @description = @movie_details['overview'] || "No description available"
    tmdb_genres = @movie_details['genres'] || []
    tmdb_cast = fetch_combined_cast(@title.tmdb_id, tmdb_api, @title.media_type)

    if @title.imdb_id
      logger.debug "Fetching OMDb details for IMDb ID: #{@title.imdb_id}"
      omdb_details = omdb_api.fetch_movie_details(@title.imdb_id) || {}
      @imdb_rating = omdb_details['imdbRating'] || "N/A"
      @imdb_votes = omdb_details['imdbVotes']&.gsub(',', '')&.to_i || 0
      omdb_genres = omdb_details['Genre']&.split(", ") || []
      omdb_cast = omdb_details['Actors']&.split(", ") || []

      combined_genres = (tmdb_genres.map { |g| g['name'] } + omdb_genres).uniq
      combined_cast = (tmdb_cast + omdb_cast).uniq

      @genres = combined_genres.join(", ")
      @cast = combined_cast.join(", ")
    else
      @imdb_rating = "N/A"
      @imdb_votes = 0
      @genres = tmdb_genres.map { |g| g['name'] }.join(", ")
      @cast = tmdb_cast.join(", ")
    end

    logger.debug "Saving genres for title ID: #{@title.tmdb_id}"
    save_genres(tmdb_genres, omdb_genres, @title)
  end

  def fetch_combined_cast(tmdb_id, tmdb_api, media_type)
    cast_details = if media_type == 'movie'
                     tmdb_api.fetch_movie_cast(tmdb_id)
                   else
                     tmdb_api.fetch_tv_cast(tmdb_id)
                   end

    cast_details&.map { |cast_member| cast_member['name'] } || []
  end

  def map_media_type(media_type)
    case media_type
    when 'tv'
      'tv'
    when 'movie'
      'movie'
    else
      media_type
    end
  end

  def extract_years(date)
    return [nil, nil] unless date

    if date.include?('–')
      start_year, end_year = date.split('–').map(&:strip).map(&:to_i)
      end_year = nil if end_year == 0
      [start_year, end_year]
    else
      [date.split('-').first.to_i, nil]
    end
  end
end
