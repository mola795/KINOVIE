class UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:username])
    if @user.nil?
      redirect_to root_path, alert: "User not found."
    else
      @lists = @user.lists.order(:created_at)
      @follows = @user.follows
      @list_activity = @user.activity.reverse
    end
  end

  def follow
    @user_to_follow = User.find_by(username: params[:username])
    current_user.favorite(@user_to_follow) if @user_to_follow
  end

  def unfollow
    @user_to_unfollow = User.find_by(username: params[:username])
    current_user.unfavorite(@user_to_unfollow) if @user_to_unfollow
  end
end
