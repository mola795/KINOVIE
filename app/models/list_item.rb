class ListItem < ApplicationRecord
  belongs_to :title
  belongs_to :list

  has_one :user, through: :list

  validates :title_id, presence: true
  validates :rank, presence: true

  def activity_string
    time_minutes = (Time.now - created_at) / 60
    time_string = if time_minutes <= 60
                    "#{time_minutes.round} minutes ago"
                  elsif time_minutes < 1440
                    "#{(time_minutes / 60).round} hours ago"
                  else
                    created_at.strftime("%b %d, %Y")
                  end

    "#{user.first_name} added \"#{title.name}\" to \"#{list.name}\" — #{time_string}"
  end
end
