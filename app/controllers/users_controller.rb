class UsersController < ApplicationController

  def show
    @user = User.find_by(username: params[:username])
    # @lists = @user.lists.where.not(status: 'Private').order(:created_at)
    # @private_lists = @user.lists.where(status: 'Private').where.not(name: 'Watchlist').order(:created_at)
    # @watchlist = @user.lists.find_by(name: 'Watchlist')
    @lists = @user.lists.order(:created_at)
    @follows = @user.follows
    @list_activity = @user.activity.reverse.map do |list|
      list.activity_string
    end
  end

  def follow
    @user_to_follow = User.find_by(username: params[:username])
    # debugger
    current_user.favorite(@user_to_follow)
  end

  def unfollow
    @user_to_unfollow = User.find_by(username: params[:username])
    # debugger
    current_user.unfavorite(@user_to_unfollow)
  end
end
