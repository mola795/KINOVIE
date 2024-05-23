class SearchController < ApplicationController
  def index
    @query = params[:query]

    if @query.present?
      tmdb_api = TmdbApi.new(ENV['TMDB_API_KEY'])
      tmdb_results = tmdb_api.search_movies_and_tv_shows(@query, 10)

      logger.debug "TMDb Results: #{tmdb_results.inspect}"

      @titles = tmdb_results.map do |tmdb_title|
        # start_year, end_year = extract_years(tmdb_title['release_date'] || tmdb_title['first_air_date'])

        # {
        #   id: tmdb_title['id'],
        #   name: tmdb_title['title'] || tmdb_title['name'],
        #   media_type: tmdb_title['media_type'],
        #   start_year: start_year,
        #   end_year: end_year,
        #   poster_path: tmdb_title['poster_path']
        # }

      tmdb_id = tmdb_title['id']
      media_type = tmdb_title['media_type']

      tmdb_api_key = ENV['TMDB_API_KEY']
      omdb_api_key = ENV['OMDB_API_KEY']
      tmdb_api = TmdbApi.new(tmdb_api_key)
      omdb_api = OmdbApi.new(omdb_api_key)

      logger.debug "Creating title with TMDb ID: #{tmdb_id}, Media Type: #{media_type}"

      begin
        tmdb_details = tmdb_api.fetch_title_details(tmdb_id, media_type)

        if tmdb_details.present?
          title_name = tmdb_details['title'] || tmdb_details['name']
          release_year = extract_years(tmdb_details['release_date'] || tmdb_details['first_air_date']).first

          imdb_id = tmdb_details['imdb_id'] || omdb_api.fetch_imdb_id(title_name, release_year)

          omdb_details = omdb_api.fetch_movie_details(imdb_id)

# tmdb_details['genre']
# serach your genre table if this exist
# if it exist genre = Genre.find_by_name(tmdb_details['genre'])
# if it doesnt exist genere = Genre.new()

          t = Title.find_or_create_by(
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
            # create a joint table instance between title and genre
      end

      logger.debug "Processed Titles: #{@titles.inspect}"

      rescue => e
        logger.error "Error creating title: #{e.message}"
        redirect_to new_title_path, alert: 'An error occurred while creating the title.'
      end
      t
    end
    else
      @titles = []
    end
  end

  private

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
