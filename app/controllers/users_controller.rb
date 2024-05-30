class UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:username])
    if @user.nil?
      redirect_to root_path, alert: "User not found."
    else
      @lists = @user.lists.order(:created_at)
      @follows = @user.follows
      @list_activity = @user.activity.reverse

      # Count movies and TV shows in the Ratings list
      ratings_list = @user.lists.find_by(name: 'Ratings')
      if ratings_list
        @movies_count = ratings_list.list_items.joins(:title).where(titles: { media_type: 'movie' }).count
        @tv_shows_count = ratings_list.list_items.joins(:title).where(titles: { media_type: 'tv' }).count
      else
        @movies_count = 0
        @tv_shows_count = 0
      end

      # Count lists excluding Watchlist and Ratings
      @lists_count = @user.lists.where.not(name: ['Watchlist', 'Ratings']).count
    end

    @rated_titles = Title
      .joins(:reviews)
      .where(reviews: { user_id: @user.id })
      .select('titles.*, reviews.rating')
      .order('reviews.rating DESC')
      .limit(6)

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
