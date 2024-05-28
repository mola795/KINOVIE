class Title < ApplicationRecord
  has_many :list_items, dependent: :destroy
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
    all_review.map{ |review| review.rating }.sum / all_review.count
  end

  def ordered_reviews
    reviews.order(rating: :desc)
  end
end
