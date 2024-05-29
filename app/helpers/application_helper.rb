module ApplicationHelper
  def display_streaming_type(streaming_type)
    case streaming_type
    when 'free' then 'Free Stream'
    when 'sub' then 'Paid Stream'
    when 'buy' then 'Buy'
    when 'rent' then 'Rent'
    end
  end

  def activity_string(activity)
    case activity
    when List, ListItem, Review
      activity.activity_string
    end
  end

  def top_three_reviews(reviews)
    if user_signed_in?
      reviews.where(user: current_user.favorited_users).order(rating: :desc).limit(3)
    else
      reviews.order(rating: :desc).limit(3)
    end
  end
end
