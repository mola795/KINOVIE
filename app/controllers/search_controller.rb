class SearchController < ApplicationController
  def index
    @query = params[:query]

    if @query.present?
      tmdb_api = TmdbApi.new(ENV['TMDB_API_KEY'])
      tmdb_results = tmdb_api.search_movies_and_tv_shows(@query, 12)

      @titles = tmdb_results.map do |tmdb_title|
        media_type = tmdb_title['media_type']
        tmdb_id = tmdb_title['id']
        create_or_find_title(tmdb_id, media_type)
      end
    else
      @titles = []
    end
  end

  private

  def create_or_find_title(tmdb_id, media_type)
    title = Title.find_by(tmdb_id: tmdb_id, media_type: media_type)
    return title if title

    tmdb_api_key = ENV['TMDB_API_KEY']
    omdb_api_key = ENV['OMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    omdb_api = OmdbApi.new(omdb_api_key)

    tmdb_details = tmdb_api.fetch_title_details(tmdb_id, media_type)
    return unless tmdb_details.present?

    title_name = tmdb_details['title'] || tmdb_details['name']
    release_year = extract_years(tmdb_details['release_date'] || tmdb_details['first_air_date']).first
    imdb_id = tmdb_details['imdb_id'] || omdb_api.fetch_imdb_id(title_name, release_year)
    omdb_details = omdb_api.fetch_movie_details(imdb_id)

    poster_url = "https://image.tmdb.org/t/p/w500#{tmdb_details['poster_path']}"
    logger.debug "Poster URL: #{poster_url}"  # Debug-Log für Poster-URL

    title = Title.create!(
      name: title_name,
      media_type: media_type == 'tv' ? 'tv' : 'movie',
      start_year: release_year,
      end_year: extract_years(tmdb_details['last_air_date']).first,
      tmdb_id: tmdb_id,
      imdb_id: imdb_id,
      poster_url: poster_url,
      imdb_rating: omdb_details['imdbRating'],
      imdb_votes: omdb_details['imdbVotes']&.gsub(',', '')&.to_i
    )

    save_genres(tmdb_details['genres'], title) if title.persisted?
    title
  end

  def save_genres(tmdb_genres, title)
    tmdb_genres.each do |tmdb_genre|
      genre = Genre.find_or_initialize_by(tmdb_id: tmdb_genre['id'])
      genre.name = tmdb_genre['name']
      if genre.save
        title.genres << genre unless title.genres.include?(genre)
      end
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
