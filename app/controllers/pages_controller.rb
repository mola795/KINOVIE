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

    return unless user_signed_in?

    friend_titles_with_ratings =
      Title
        .joins(reviews: { user: :lists })
        .where(lists: { name: 'Ratings', user: current_user.favorited_users })
        .select('titles.*, reviews.rating AS review_rating, users.id AS user_id')

    title_ratings = Hash.new { |hash, key| hash[key] = [] }

    friend_titles_with_ratings.each do |title|
      title_ratings[title.id] << title.review_rating
    end

    sorted_titles = title_ratings.map do |title_id, ratings|
      { title_id: title_id, average_rating: ratings.sum.to_f / ratings.size }
    end.sort_by { |hash| -hash[:average_rating] }

    @titles = Title.where(id: sorted_titles.map { |hash| hash[:title_id] }).limit(20)

    @friends_activity = current_user.friends_activity
  end

  def activity
    @all_activity = current_user.all_activity
  end

  def like
    raise
  end
end
