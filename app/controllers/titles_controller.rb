class TitlesController < ApplicationController
  def index
    @titles = Title.all
  end

  def show
    @title = Title.find(params[:id])
    tmdb_api_key = ENV['TMDB_API_KEY']
    tmdb_api = TmdbApi.new(tmdb_api_key)

    @movie_details = tmdb_api.fetch_movie_details(@title.tmdb_id)
    @description = @movie_details['overview']
    @genres = @movie_details['genres'].map { |genre| genre['name'] }.join(", ")
    @cast = tmdb_api.fetch_movie_cast(@title.tmdb_id).map { |cast_member| cast_member['name'] }.join(", ")
  end

  def popular
    @titles = Title.where(media_type: 'movie').order('created_at DESC').limit(20)
    @total_titles_count = Title.count
  end
end
