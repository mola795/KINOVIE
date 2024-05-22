class Title < ApplicationRecord
  has_many :list_items
  has_many :reviews
  has_many :genre_connections
  has_many :genres, through: :genre_connections
  has_many :people_titles
  has_many :people, through: :people_titles
  has_many :streamings
  has_many :services, through: :streamings

  validates :name, presence: true

  include PgSearch::Model
  pg_search_scope :search_by_name, against: :name

end
