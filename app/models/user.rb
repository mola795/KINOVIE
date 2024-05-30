class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :followers, through: :follows, source: :followers
  has_many :followings, through: :follows, source: :followed

  has_many :lists, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :list_items, through: :lists, dependent: :destroy

  acts_as_favoritor
  acts_as_favoritable

  has_one_attached :profile_picture

  def activity
    activities = lists + list_items + reviews
    activities.sort_by(&:created_at).reverse.first(10)
  end

  def friends_activity
    self.favorited_users.flat_map(&:activity).sort_by(&:created_at).reverse.first(10)
  end

  def all_activity
    (activity + friends_activity).sort_by(&:created_at).reverse
  end

  def find_user_watchlist
    self.lists.find_by(name: "Watchlist")
  end
end
