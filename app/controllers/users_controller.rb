class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @lists = @user.lists.where.not(status: 'Private').order(:created_at)
    @private_lists = @user.lists.where(status: 'Private').where.not(name: 'Watchlist').order(:created_at)
    @watchlist = @user.lists.find_by(name: 'Watchlist')
  end
end

# def index
#   @lists = current_user.lists.order(:created_at)
#   @watchlist = @lists.find_by(name: 'Watchlist')
#   @lists = @lists.where.not(id: @watchlist.id) if @watchlist
# end
