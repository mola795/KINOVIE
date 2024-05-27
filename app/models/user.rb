class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :followers, through: :follows, source: :followed
  has_many :following, through: :follows, source: :follower

  has_many :lists, dependent: :destroy
  has_many :reviews, dependent: :destroy

  has_many :comments, dependent: :destroy
  has_many :list_items, through: :lists, dependent: :destroy

  acts_as_favoritor
  acts_as_favoritable

  def activity
    #  @reviews = self.reviews
    #  @followers = self.followers
    #  @followings = self.following
    #  @comments = self.comments
     @list_item = self.list_items
     @lists = self.lists.where.not(name: "Watchlist")
     # add @reviews + @followers + @followings + @comments later to the below function
     @activities = @list_item + @lists
     @activities.sort_by(&:created_at)
  end
end
