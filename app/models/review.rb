class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title
  has_many :comments, as: :commentable

  validates :rating, presence: true
  validates :rating, presence: true, inclusion: { in: 1..10 }

  acts_as_favoritable
end
