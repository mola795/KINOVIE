class SearchController < ApplicationController
  def index
    @query = params[:query]
    @titles = Title.search_by_name(@query)
  end
end
