class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title
  has_many :comments, as: :commentable

  validates :rating, presence: true
  validates :rating, inclusion: { in: 1..10 }

  acts_as_favoritable

  def activity_string
    time_minutes = (Time.now - created_at) / 60
    time_string = if time_minutes <= 60
                    "#{time_minutes.round} minutes ago"
                  elsif time_minutes < 1440
                    "#{(time_minutes / 60).round} hours ago"
                  else
                    created_at.strftime("%b %d, %Y")
                  end

    comment_text = comment.present? ? " Comment: #{comment}" : ""
    "#{user.username} reviewed \"#{title.name}\" — #{time_string}. Rating: #{rating}.#{comment_text}"
  end
end
