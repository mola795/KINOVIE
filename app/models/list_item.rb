class ListItem < ApplicationRecord
  belongs_to :title
  belongs_to :list

  has_one :user, through: :list

  validates :title_id, presence: true
  validates :rank, presence: true

  def activity_string
    time_minutes = (Time.now - created_at) / 60
      if time_minutes <= 60
        "You added \"#{self.title.name}\" to \"#{self.list.name}\" — #{time_minutes.round} minutes ago"
      elsif time_minutes > 60 && time_minutes < 1440
        time_hours = (time_minutes / 60).round
        "You added \"#{self.title.name}\" to \"#{self.list.name}\" — #{time_hours} #{time_hours == 1 ? "hour" : "hours" } ago"
      else
        "You added \"#{self.title.name}\" to \"#{self.list.name}\" — #{created_at.strftime("%b %d, %Y")} ago"
      end
  end
end
