class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title

  validates :rating, presence: true

  acts_as_favoritable
end
