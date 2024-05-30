class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @lists = List.where.not(name: ['Watchlist'])
    @genres = Genre.where.not(cover_url: nil)
  end

  def show
    @list = List.includes(:user).find(params[:id])
    @list_items = if @list.name == 'Watchlist' || @list.name == 'Ratings'
                    @list.list_items.order(created_at: :desc) # Sortierung nach Erstellungsdatum
                  else
                    @list.list_items.order(:rank)
                  end

    friend_titles =
      Title
        .joins(:lists)
        .where(lists: { user: current_user.favorited_users })
        .distinct

    your_title =
      Title
        .joins(:lists)
        .where(lists: { name: "Watchlist", user: current_user })

    @toplist = (friend_titles & your_title).max_by(3) { |title| title.average_rating_title }
  end
end
