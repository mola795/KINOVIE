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
end
