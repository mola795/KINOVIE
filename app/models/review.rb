class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title
  has_many :comments, as: :commentable

  validates :rating, presence: true, inclusion: { in: 1..10 }

  acts_as_favoritable

  after_create :after_create_add_to_ratings_list
  before_destroy :before_destroy_remove_from_ratings_list

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
    "#{user.first_name} reviewed \"#{title.name}\" — #{time_string}. Rating: #{rating}.#{comment_text}"
  end

  private

  def after_create_add_to_ratings_list
    user.lists.find_or_create_by(name: 'Ratings') do |list|
      list.description = 'All the titles I have rated.'
      list.status = 'Private'
    end.list_items.find_or_create_by(title: title)
  end

  def before_destroy_remove_from_ratings_list
    list = user.lists.find_by(name: 'Ratings')
    list_item = list.list_items.find_by(title: title)
    list_item.destroy if list_item
  end
end
