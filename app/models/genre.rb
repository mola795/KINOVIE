class Genre < ApplicationRecord
  has_many :genre_connections, dependent: :destroy
  has_many :titles, through: :genre_connections
  has_many :lists, through: :genre_connections

  validates :name, presence: true
end
