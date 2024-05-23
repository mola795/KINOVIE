class SearchController < ApplicationController
  def index
    @query = params[:query]

    if @query.present?
      tmdb_api = TmdbApi.new(ENV['TMDB_API_KEY'])
      tmdb_results = tmdb_api.search_movies_and_tv_shows(@query, 10)

      logger.debug "TMDb Results: #{tmdb_results.inspect}"

      @titles = tmdb_results.map do |tmdb_title|
        start_year, end_year = extract_years(tmdb_title['release_date'] || tmdb_title['first_air_date'])

        {
          id: tmdb_title['id'],
          name: tmdb_title['title'] || tmdb_title['name'],
          media_type: tmdb_title['media_type'],
          start_year: start_year,
          end_year: end_year,
          poster_path: tmdb_title['poster_path']
        }
      end

      logger.debug "Processed Titles: #{@titles.inspect}"
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
