class TitlesController < ApplicationController
  def index
    @titles = Title.all
  end

  def popular
    @titles = Title.where(media_type: ['movie', 'tv']).order('created_at DESC').limit(40)
    @total_titles_count = Title.count
  end

  def show
    @title = Title.find(params[:id])
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
    tmdb_api_key = ENV['TMDB_API_KEY']
    omdb_api_key = ENV['OMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    omdb_api = OmdbApi.new(omdb_api_key)

    tmdb_id = params[:title][:tmdb_id]
    media_type = params[:title][:media_type]

    begin
      tmdb_details = tmdb_api.fetch_title_details(tmdb_id, media_type)

      if tmdb_details.present?
        title_name = tmdb_details['title'] || tmdb_details['name']
        release_year = extract_years(tmdb_details['release_date'] || tmdb_details['first_air_date']).first

        imdb_id = tmdb_details['imdb_id'] || omdb_api.fetch_imdb_id(title_name, release_year)

        omdb_details = omdb_api.fetch_movie_details(imdb_id)

        @title = Title.new(
          name: title_name,
          media_type: media_type == 'tv' ? 'tv' : 'movie',
          start_year: release_year,
          end_year: extract_years(tmdb_details['last_air_date']).first,
          tmdb_id: tmdb_id,
          imdb_id: imdb_id,
          poster_url: "https://image.tmdb.org/t/p/w500#{tmdb_details['poster_path']}",
          imdb_rating: omdb_details['imdbRating'],
          imdb_votes: omdb_details['imdbVotes']&.gsub(',', '')&.to_i
        )

        if @title.save
          redirect_to @title, notice: 'Title was successfully created.'
        else
          render :new, status: :unprocessable_entity
        end
      else
        redirect_to new_title_path, alert: 'Title not found in TMDb.'
      end
    rescue => e
      logger.error "Error creating title: #{e.message}"
      redirect_to new_title_path, alert: 'An error occurred while creating the title.'
    end

    @list_item = ListItem.new

  end

  private

  def fetch_and_display_title_details
    tmdb_api_key = ENV['TMDB_API_KEY']
    omdb_api_key = ENV['OMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    omdb_api = OmdbApi.new(omdb_api_key)

    media_type = map_media_type(@title.media_type)
    @movie_details = tmdb_api.fetch_title_details(@title.tmdb_id, media_type)

    if @movie_details.blank?
      raise ActiveRecord::RecordNotFound, "Title details not found in TMDb response"
    end

    @description = @movie_details['overview'] || "No description available"
    tmdb_genres = @movie_details['genres']&.map { |genre| genre['name'] } || []
    tmdb_cast = fetch_combined_cast(@title.tmdb_id, tmdb_api, @title.media_type)

    if @title.imdb_id
      omdb_details = omdb_api.fetch_movie_details(@title.imdb_id) || {}
      @imdb_rating = omdb_details['imdbRating'] || "N/A"
      @imdb_votes = omdb_details['imdbVotes']&.gsub(',', '')&.to_i || 0
      omdb_genres = omdb_details['Genre']&.split(", ") || []
      omdb_cast = omdb_details['Actors']&.split(", ") || []

      combined_genres = (tmdb_genres + omdb_genres).uniq
      combined_cast = (tmdb_cast + omdb_cast).uniq

      @genres = combined_genres.join(", ")
      @cast = combined_cast.join(", ")
    else
      @imdb_rating = "N/A"
      @imdb_votes = 0
      @genres = tmdb_genres.join(", ")
      @cast = tmdb_cast.join(", ")
    end
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
