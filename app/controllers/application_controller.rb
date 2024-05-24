class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def create_or_find_title(tmdb_id, media_type)
    existing_title = Title.find_by(tmdb_id: tmdb_id, media_type: media_type)
    return existing_title if existing_title

    tmdb_api_key = ENV['TMDB_API_KEY']
    omdb_api_key = ENV['OMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)
    omdb_api = OmdbApi.new(omdb_api_key)

    begin
      tmdb_details = tmdb_api.fetch_title_details(tmdb_id, media_type)

      if tmdb_details.present?
        title_name = tmdb_details['title'] || tmdb_details['name']
        release_year = extract_years(tmdb_details['release_date'] || tmdb_details['first_air_date']).first

        imdb_id = tmdb_details['imdb_id'] || omdb_api.fetch_imdb_id(title_name, release_year)
        omdb_details = omdb_api.fetch_movie_details(imdb_id)

        poster_path = tmdb_details['poster_path']
        poster_url = poster_path.present? ? "https://image.tmdb.org/t/p/w500#{poster_path}" : nil

        imdb_votes = omdb_details['imdbVotes']&.gsub(',', '')&.to_i || 0

        title = Title.new(
          name: title_name,
          media_type: media_type == 'tv' ? 'tv' : 'movie',
          start_year: release_year,
          end_year: extract_years(tmdb_details['last_air_date']).first,
          tmdb_id: tmdb_id,
          imdb_id: imdb_id,
          poster_url: poster_url,
          imdb_rating: omdb_details['imdbRating'],
          imdb_votes: imdb_votes
        )

        if title.save
          save_genres(tmdb_details['genres'], title)
          return title
        else
          logger.error "Error saving title: #{title.errors.full_messages.join(', ')}"
          return nil
        end
      else
        logger.error "TMDb details not found for ID: #{tmdb_id}"
        return nil
      end
    rescue => e
      logger.error "Error creating title: #{e.message}"
      return nil
    end
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

  def fetch_titles_by_genre(genre_id, media_type, page = 1)
    tmdb_api_key = ENV['TMDB_API_KEY']
    url = URI("https://api.themoviedb.org/3/discover/#{media_type}?api_key=#{tmdb_api_key}&with_genres=#{genre_id}&language=en-US&page=#{page}")
    response = Net::HTTP.get(url)
    JSON.parse(response)["results"]
  rescue => e
    Rails.logger.error "Error fetching #{media_type} titles for genre #{genre_id}: #{e.message}"
    []
  end

  def fetch_and_save_additional_titles(genre_id, existing_tmdb_ids, media_type, limit)
    additional_titles = []
    page = 1
    while additional_titles.size < limit
      titles = fetch_titles_by_genre(genre_id, media_type, page)
      titles.reject! { |title| existing_tmdb_ids.include?(title['id']) }
      titles.each do |title_data|
        title = create_or_find_title(title_data['id'], media_type)
        if title && (title.imdb_votes || 0) > 0
          additional_titles << title
          existing_tmdb_ids << title.tmdb_id
        end
        break if additional_titles.size >= limit
      end
      break if titles.empty?
      page += 1
    end
  end
end
