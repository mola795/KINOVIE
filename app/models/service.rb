class Service < ApplicationRecord
  has_many :streamings, dependent: :destroy
  has_many :titles, through: :streamings

  validates :name, presence: true
end
