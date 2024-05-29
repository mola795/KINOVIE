class List < ApplicationRecord
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :titles, through: :list_items
  has_many :genre_connections, dependent: :destroy
  has_many :genres, through: :genre_connections

  validates :name, presence: true

  accepts_nested_attributes_for :genre_connections, allow_destroy: true, reject_if: :all_blank
  acts_as_favoritable

  def activity_string
    time_minutes = (Time.now - created_at) / 60
    if time_minutes <= 60
      "#{user.username} created \"#{name}\" — #{time_minutes.round} minutes ago"
    elsif time_minutes > 60 && time_minutes < 1440
      time_hours = (time_minutes / 60).round
      "#{user.username} created \"#{name}\" — #{time_hours} #{time_hours == 1 ? 'hour' : 'hours'} ago"
    else
      "#{user.username} created \"#{name}\" — #{created_at.strftime('%b %d, %Y')}"
    end
  end
end
