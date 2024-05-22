class SearchController < ApplicationController
  def index
    @query = params[:query]
    @titles = Title.search_by_name(@query)

    if @titles.empty?
      tmdb_api = TmdbApi.new(ENV['TMDB_API_KEY'])
      tmdb_results = tmdb_api.search_movies_and_tv_shows(@query, 5)

      @titles = tmdb_results.map do |tmdb_title|
        Title.find_or_create_by(tmdb_id: tmdb_title['id']) do |t|
          t.name = tmdb_title['title'] || tmdb_title['name']
          t.media_type = tmdb_title['media_type']
          t.start_year, t.end_year = extract_years(tmdb_title['release_date'] || tmdb_title['first_air_date'])
          t.poster_url = "https://image.tmdb.org/t/p/w500/#{tmdb_title['poster_path']}"
          t.imdb_id = fetch_imdb_id(tmdb_title['id'], tmdb_api, t.media_type)
        end
      end
    end
  end

  private

  def fetch_imdb_id(tmdb_id, tmdb_api, media_type)
    title_details = tmdb_api.fetch_title_details(tmdb_id, media_type)
    title_details['imdb_id']
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
