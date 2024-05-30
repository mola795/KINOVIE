class Review < ApplicationRecord
  belongs_to :user
  belongs_to :title
  has_many :comments, as: :commentable

  validates :rating, presence: true, inclusion: { in: 1..10 }

  acts_as_favoritable

  after_create :add_to_ratings_list
  before_destroy :remove_from_ratings_list

  def activity_string
    time_minutes = (Time.now - created_at) / 60
    time_string = if time_minutes <= 60
                    "#{time_minutes.round} minutes ago"
                  elsif time_minutes < 1440
                    "#{(time_minutes / 60).round} hours ago"
                  else
                    created_at.strftime("%b %d, %Y")
                  end

    # comment_text = comment.present? ? " Comment: #{comment}" : ""
    "— #{time_string}"
  end

  private

  def add_to_ratings_list
    list = user.lists.find_or_create_by(name: 'Ratings') do |list|
      list.description = 'All the titles I have rated.'
      list.status = 'Private'
    end

    list_item = list.list_items.find_or_initialize_by(title: title)
    list_item.rank = list.list_items.count + 1 unless list_item.persisted?
    list_item.save unless list_item.persisted?
  end

  def remove_from_ratings_list
    list = user.lists.find_by(name: 'Ratings')
    return unless list

    list_item = list.list_items.find_by(title: title)
    list_item.destroy if list_item
  end
end
