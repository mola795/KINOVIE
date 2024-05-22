class Service < ApplicationRecord
  has_many :streamings
  has_many :titles, through: :streamings

  validates :name, presence: true
end
