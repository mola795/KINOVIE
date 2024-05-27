class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title

  validates :rating, presence: true, inclusion: { in: 1..10 }
  validates :user_id, uniqueness: { scope: :title_id }

  private

  def validate_uniqueness_of_review
    errors.add(:user_id, "can only rate a title once") if Review.exists?(user: user, title: title)
  end
end
