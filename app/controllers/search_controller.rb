class SearchController < ApplicationController
  def index
    @query = params[:query]
    @titles = Title.where("name ILIKE ?", "%#{@query}%")
    @genres = Genre.where("name ILIKE ?", "%#{@query}%")
  end
end
