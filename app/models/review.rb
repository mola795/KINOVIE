class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title

  validates :rating, presence: true, inclusion: { in: 1..10 }

end
