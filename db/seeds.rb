require 'httparty'
require 'concurrent-ruby'
require_relative '../lib/tmdb_api'
require_relative '../lib/omdb_api'
require 'faker'

puts "Cleaning the DB..."
GenreConnection.destroy_all
Streaming.destroy_all
ListItem.destroy_all
Review.destroy_all
Title.destroy_all
List.destroy_all

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

def map_media_type(media_type)
  case media_type
  when 'movie'
    'movie'
  when 'series'
    'tv'
  when 'episode'
    'episode'
  else
    media_type
  end
end

def seed_top_rated_titles(tmdb_api, omdb_api)
  total_movies_needed = 200
  total_tv_shows_needed = 100
  movies_per_page = 20
  tv_shows_per_page = 20
  total_movie_pages = (total_movies_needed / movies_per_page.to_f).ceil
  total_tv_show_pages = (total_tv_shows_needed / tv_shows_per_page.to_f).ceil
  all_movies = Concurrent::Array.new
  all_tv_shows = Concurrent::Array.new

  (1..total_movie_pages).each do |page|
    movies = tmdb_api.fetch_top_rated_movies(page)
    break if movies.nil?

    all_movies.concat(movies)
    break if all_movies.size >= total_movies_needed
  end

  (1..total_tv_show_pages).each do |page|
    tv_shows = tmdb_api.fetch_top_rated_tv_shows(page)
    break if tv_shows.nil?

    all_tv_shows.concat(tv_shows)
    break if all_tv_shows.size >= total_tv_shows_needed
  end

  puts "Starting to seed top-rated movies..."

  movie_counter = 0
  batch_size = 4

  all_movies.first(total_movies_needed).each_slice(batch_size) do |batch|
    futures = batch.map do |title|
      Concurrent::Promises.future do
        begin
          sleep(0.1)
          media_type = 'movie'
          puts "Processing title: #{title['title']} (#{media_type})"

          tmdb_details = tmdb_api.fetch_title_details(title['id'], media_type)
          start_year, end_year = extract_years(tmdb_details['release_date'])

          imdb_id = tmdb_details['imdb_id']
          if imdb_id.nil? || imdb_id.empty?
            imdb_id = omdb_api.fetch_imdb_id(title['title'], start_year)
          end

          imdb_rating = nil
          imdb_votes = 0
          omdb_media_type = nil
          if imdb_id
            omdb_details = omdb_api.fetch_movie_details(imdb_id)
            imdb_rating = omdb_details['imdbRating']
            imdb_votes = omdb_details['imdbVotes'].gsub(',', '').to_i if omdb_details['imdbVotes']
            omdb_media_type = omdb_details['Type']

            if media_type == 'tv' && omdb_details['Year'].include?('–')
              start_year, end_year = extract_years(omdb_details['Year'])
            end
          end

          media_type = map_media_type(omdb_media_type) if omdb_media_type && omdb_media_type != media_type

          title_record = Title.create!(
            name: title['title'],
            media_type: media_type,
            start_year: start_year,
            end_year: end_year,
            tmdb_id: title['id'],
            imdb_id: imdb_id,
            poster_url: "https://image.tmdb.org/t/p/w500#{title['poster_path']}",
            imdb_rating: imdb_rating,
            imdb_votes: imdb_votes
          )

          puts "Created title: #{title['title']} (TMDb ID: #{title['id']}, IMDb ID: #{imdb_id}, IMDb Rating: #{imdb_rating}, IMDb Votes: #{imdb_votes})"

          # Save genres
          save_genres(tmdb_details['genres'], title_record)

          movie_counter += 1
          puts "Added movie ##{movie_counter} with start year: #{start_year}"

        rescue => e
          puts "Error processing title #{title['title']}: #{e.message}"
        end
      end
    end

    # Wait for all futures in the batch to complete
    Concurrent::Promises.zip(*futures).value!

    sleep(0.1)
  end

  puts "Starting to seed top-rated TV shows..."

  tv_show_counter = 0

  all_tv_shows.first(total_tv_shows_needed).each_slice(batch_size) do |batch|
    futures = batch.map do |title|
      Concurrent::Promises.future do
        begin
          sleep(0.1)
          media_type = 'tv'
          puts "Processing title: #{title['name']} (#{media_type})"

          tmdb_details = tmdb_api.fetch_title_details(title['id'], media_type)
          start_year, end_year = extract_years(tmdb_details['first_air_date'])

          imdb_id = tmdb_details['imdb_id']
          if imdb_id.nil? || imdb_id.empty?
            imdb_id = omdb_api.fetch_imdb_id(title['name'], start_year)
          end

          imdb_rating = nil
          imdb_votes = 0
          omdb_media_type = nil
          if imdb_id
            omdb_details = omdb_api.fetch_movie_details(imdb_id)
            imdb_rating = omdb_details['imdbRating']
            imdb_votes = omdb_details['imdbVotes'].gsub(',', '').to_i if omdb_details['imdbVotes']
            omdb_media_type = omdb_details['Type']

            if media_type == 'tv' && omdb_details['Year'].include?('–')
              start_year, end_year = extract_years(omdb_details['Year'])
            end
          end

          media_type = map_media_type(omdb_media_type) if omdb_media_type && omdb_media_type != media_type

          title_record = Title.create!(
            name: title['name'],
            media_type: media_type,
            start_year: start_year,
            end_year: end_year,
            tmdb_id: title['id'],
            imdb_id: imdb_id,
            poster_url: "https://image.tmdb.org/t/p/w500#{title['poster_path']}",
            imdb_rating: imdb_rating,
            imdb_votes: imdb_votes
          )

          puts "Created title: #{title['name']} (TMDb ID: #{title['id']}, IMDb ID: #{imdb_id}, IMDb Rating: #{imdb_rating}, IMDb Votes: #{imdb_votes})"

          # Save genres
          save_genres(tmdb_details['genres'], title_record)

          tv_show_counter += 1
          puts "Added TV show ##{tv_show_counter} with start year: #{start_year}"

        rescue => e
          puts "Error processing title #{title['name']}: #{e.message}"
        end
      end
    end

    # Wait for all futures in the batch to complete
    Concurrent::Promises.zip(*futures).value!

    sleep(0.1)
  end

  puts "Seeding completed."
end

def save_genres(tmdb_genres, title)
  tmdb_genres.each do |tmdb_genre|
    genre = create_or_find_genre(tmdb_genre)
    title.genres << genre unless title.genres.include?(genre)
    puts "Saved genre: #{genre.name} for title: #{title.name}"
  end
end

def create_or_find_genre(tmdb_genre)
  genre = Genre.find_or_initialize_by(tmdb_id: tmdb_genre['id'])
  genre.name = tmdb_genre['name']

  genre.save! if genre.new_record?
  puts "Created or found genre: #{genre.name} (TMDb ID: #{genre.tmdb_id})"
  genre
end

def seed_users_and_lists
  ignored_genres = ["TV Movie", "Talk", "Kids", "Reality"]
  genres = Genre.where.not(name: ignored_genres)
  reviews_comments = [
    "Amazing! A must-watch.",
    "Really enjoyed it!",
    "Solid performance and great plot.",
    "Would recommend!",
    "Not my cup of tea, but well made.",
    "Fantastic visuals!",
    "Good, but could be better.",
    "Quite entertaining.",
    "Loved the storyline.",
    "Great direction and acting."
  ]

  30.times do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    username = "#{first_name}_#{last_name}"

    user = User.create!(
      email: Faker::Internet.unique.email,
      password: 'password',
      password_confirmation: 'password',
      first_name: first_name,
      last_name: last_name,
      username: username.downcase,
      bio: "I love movies and TV shows",
      profile_picture_url: Faker::Avatar.image
    )

    genres.each do |genre|
      ['movie', 'tv'].each do |media_type|
        genre_titles = genre.titles.where(media_type: media_type)

        # Check if the genre contains titles of the selected media type
        next if genre_titles.empty?

        list_name = media_type == 'tv' ? "The best #{genre.name} TV Shows" : "The best #{genre.name} Movies"

        list = user.lists.create!(
          name: list_name,
          description: "Hi my name is #{user.first_name} and this is my #{genre.name} #{media_type} list",
          status: 'Public'
        )

        genre_titles.sample(5).each_with_index do |title, index|
          list_item = list.list_items.create!(title: title, rank: index + 1)

          # Add a review for each title added to the list
          user.reviews.create!(
            title: title,
            rating: rand(6..10),
            comment: reviews_comments.sample
          )
        end

        list.genre_connections.create!(genre: genre)
        puts "Created list: #{list.name} for user: #{user.username} and added reviews for each title in the list."
      end
    end
  end
end

puts "Seeding top-rated movies and popular TV shows from TMDb..."
tmdb_api_key = ENV['TMDB_API_KEY']
omdb_api_key = ENV['OMDB_API_KEY']
tmdb_api = TmdbApi.new(tmdb_api_key)
omdb_api = OmdbApi.new(omdb_api_key)
seed_top_rated_titles(tmdb_api, omdb_api)

puts "Seeding users and their crazy lists..."
seed_users_and_lists

puts "Seeding completed."
