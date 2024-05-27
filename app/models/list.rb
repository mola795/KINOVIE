class List < ApplicationRecord
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :titles, through: :list_items
  has_many :genre_connections, dependent: :destroy
  has_many :genres, through: :genre_connections

  validates :name, presence: true

  accepts_nested_attributes_for :genre_connections, allow_destroy: true, reject_if: :all_blank
  acts_as_favoritable
end
