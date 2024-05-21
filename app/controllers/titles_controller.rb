class TitlesController < ApplicationController
  def index
    @titles = Title.all
  end

  def show
    @title = Title.find(params[:id])
  end

  def popular
    @titles = Title.where(media_type: 'movie').order('created_at DESC').limit(20)
  end
end
