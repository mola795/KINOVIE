class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @genres = Genre.where.not(cover_url: nil)
                   .where.not(name: ["Animation", "TV Movie", "Kids", "Documentary", "War"])
                   .sample(12)
    @lists = List.includes(:user)
                 .where.not(name: ['Watchlist', 'Ratings'])
                 .joins(:list_items)
                 .group('lists.id')
                 .having('COUNT(list_items.id) > 0')
                 .order(created_at: :desc)
    @titles = Title.limit(18)

    return unless user_signed_in?

    @friends_activity = current_user.friends_activity.reverse
  end

  def activity
    @all_activity = current_user.all_activity.reverse
  end

  # def profile
  #   @user = current_user
  #   # @lists = @user.lists.where.not(status: 'Private').order(:created_at)
  #   # @private_lists = @user.lists.where(status: 'Private').where.not(name: 'Watchlist').order(:created_at)
  #   # @watchlist = @user.lists.find_by(name: 'Watchlist')
  #   @lists = @user.lists.order(:created_at)
  #   @follows = @user.follows
  #   @list_activity = @user.activity.reverse.map do |list|
  #     list.activity_string
  #   end

  #   render 'users/show'
  # end
end
