class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title

  validates :rating, presence: true
end
