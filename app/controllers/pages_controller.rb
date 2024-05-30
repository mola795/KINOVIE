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
    @titles = Title.limit(20) || []

    @titles = Title.order("RANDOM()").limit(20)

    @users = User.where.not(user: current_user).limit(1)

    return unless user_signed_in?

    @friends_activity = current_user.friends_activity
    # raise
  end

  def activity
    @all_activity = current_user.all_activity
  end

  def like
    raise
  end
end
