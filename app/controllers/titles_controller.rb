class TitlesController < ApplicationController
  def index
    @titles = Title.all
    @total_titles_count = Title.count
  end

  def movies
    @db_movies = Title.where(media_type: 'movie').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:movie_page]).per(36)
  end

  def tv_shows
    @db_tv_shows = Title.where(media_type: 'tv').where("imdb_votes > 0").order(imdb_votes: :desc).page(params[:tv_page]).per(36)
  end

  def show
    @title = Title.find(params[:id])
    @list_item = ListItem.new
    @review = @title.reviews.find_by(user: current_user) || Review.new
    @lists = List.joins(:list_items).where(list_items: { title_id: @title.id }).distinct
    @comment = Comment.new
    @new_list = List.new
    fetch_and_display_title_details
    fetch_backdrops
    fetch_additional_details
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
    tmdb_cast = fetch_cast(@title.tmdb_id, tmdb_api, @title.media_type)

    if @title.imdb_id
      logger.debug "Fetching OMDb details for IMDb ID: #{@title.imdb_id}"
      omdb_details = omdb_api.fetch_movie_details(@title.imdb_id) || {}
      @imdb_rating = omdb_details['imdbRating'] || "N/A"
      @imdb_votes = omdb_details['imdbVotes']&.gsub(',', '')&.to_i || 0

      @genres = tmdb_genres.map { |g| g['name'] }.join(", ")
      @cast = tmdb_cast.join(", ")
    else
      @imdb_rating = "N/A"
      @imdb_votes = 0
      @genres = tmdb_genres.map { |g| g['name'] }.join(", ")
      @cast = tmdb_cast.join(", ")
    end

    logger.debug "Saving genres for title ID: #{@title.tmdb_id}"
    save_genres(tmdb_genres, @title)
  end

  def fetch_backdrops
    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    media_type = map_media_type(@title.media_type)
    @backdrops = tmdb_api.fetch_title_backdrops(@title.tmdb_id, media_type)
  end

  def fetch_additional_details
    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)

    media_type = map_media_type(@title.media_type)
    credits = tmdb_api.fetch_credits(@title.tmdb_id, media_type)

    if media_type == 'movie'
      @director = credits['crew']&.find { |member| member['job'] == 'Director' }&.dig('name')
      @writers = credits['crew']&.select { |member| member['department'] == 'Writing' }.map { |writer| writer['name'] }.join(", ")
    elsif media_type == 'tv'
      @creator = credits['crew']&.find { |member| member['job'] == 'Creator' }&.dig('name')
      @writers = credits['crew']&.select { |member| member['department'] == 'Writing' }.map { |writer| writer['name'] }.join(", ")
    end
  end

  def save_genres(tmdb_genres, title)
    tmdb_genres.each do |tmdb_genre|
      genre = create_or_find_genre(tmdb_genre)
      title.genres << genre unless title.genres.include?(genre)
    end
  end

  def create_or_find_genre(tmdb_genre)
    genre = Genre.find_or_initialize_by(tmdb_id: tmdb_genre['id'])
    genre.name = tmdb_genre['name']

    genre.save! if genre.new_record?
    genre
  end

  def create_or_find_title(tmdb_id, media_type)
    title = Title.find_by(tmdb_id: tmdb_id)
    return title if title

    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    media_type = map_media_type(media_type)
    title_details = tmdb_api.fetch_title_details(tmdb_id, media_type)

    return unless title_details

    poster_url = "https://image.tmdb.org/t/p/w500#{title_details['poster_path']}"

    Title.create(
      name: title_details['title'] || title_details['name'],
      description: title_details['overview'],
      tmdb_id: tmdb_id,
      media_type: media_type,
      imdb_id: title_details['imdb_id'],
      poster_url: poster_url
    )
  end

  def fetch_backdrop(tmdb_id, media_type)
    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    backdrops = tmdb_api.fetch_top_title_backdrop(tmdb_id, media_type)
    backdrops.first # Use the first backdrop for simplicity
  end

  def find_tmdb_genre_id_by_name(genre_name)
    tmdb_api_key = ENV['TMDB_API_KEY']
    url = URI("https://api.themoviedb.org/3/genre/movie/list?api_key=#{tmdb_api_key}&language=en-US")
    response = Net::HTTP.get(url)
    genres = JSON.parse(response)["genres"]
    genre = genres.find { |g| g['name'].casecmp(genre_name).zero? }
    genre ? genre['id'] : nil
  rescue => e
    logger.error "Error fetching TMDb genre ID: #{e.message}"
    nil
  end

  def fetch_cast(tmdb_id, tmdb_api, media_type)
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
