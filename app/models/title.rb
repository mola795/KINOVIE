class Title < ApplicationRecord
  has_many :list_items, dependent: :destroy
  has_many :lists, through: :list_items
  has_many :reviews
  has_many :genre_connections
  has_many :genres, through: :genre_connections
  has_many :people_titles
  has_many :people, through: :people_titles
  has_many :streamings, dependent: :destroy
  has_many :services, through: :streamings

  validates :name, presence: true

  include PgSearch::Model
  pg_search_scope :search_by_name, against: :name


  def average_rating_title
    all_review = self.reviews
    return 0 if all_review.count.zero?

    all_review.map{ |review| review.rating }.sum / all_review.count
  end

  def ordered_reviews
    reviews.order(rating: :desc)
  end

  def release_year
    if media_type == 'tv' && start_year != end_year
      "#{start_year} - #{end_year || 'Present'}"
    else
      start_year.to_s
    end
  end

  def in_watchlist?(watchlist)
    watchlist.list_items.find_by(title: self, list: watchlist) ? true : false
  end
end
