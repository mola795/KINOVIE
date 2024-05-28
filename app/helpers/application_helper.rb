module ApplicationHelper
  # Assign the button text for each possible streaming type
  # Used in services#show
  def display_streaming_type(streaming_type)
    case streaming_type
    when 'free' then 'Free Stream'
    when 'sub' then 'Paid Stream'
    when 'buy' then 'Buy'
    when 'rent' then 'Rent'
    end
  end

  def activity_string(activity)
    time_minutes = (Time.now - activity.created_at) / 60
    if activity.class == List
      if time_minutes <= 60
        "#{activity.user == current_user ? "You" : activity.user.username} created \"#{activity.name}\" — #{time_minutes.round} minutes ago"
      elsif time_minutes > 60 && time_minutes < 1440
        time_hours = (time_minutes / 60).round
        "#{activity.user == current_user ? "You" : activity.user.username} created \"#{activity.name}\" — #{time_hours} #{time_hours == 1 ? "hour" : "hours" } ago"
      else
        "#{activity.user == current_user ? "You" : activity.user.username} created \"#{activity.name}\" — #{activity.created_at.strftime("%b %d, %Y")}"
      end
    elsif activity.class == ListItem
      if time_minutes <= 60
        "#{activity.user == current_user ? "You" : activity.user.username} added \"#{activity.title.name}\" to \"#{activity.list.name}\" — #{time_minutes.round} minutes ago"
      elsif time_minutes > 60 && time_minutes < 1440
        time_hours = (time_minutes / 60).round
        "#{activity.user == current_user ? "You" : activity.user.username} added \"#{activity.title.name}\" to \"#{activity.list.name}\" — #{time_hours} #{time_hours == 1 ? "hour" : "hours" } ago"
      else
        "#{activity.user == current_user ? "You" : activity.user.username} added \"#{activity.title.name}\" to \"#{activity.list.name}\" — #{activity.created_at.strftime("%b %d, %Y")} ago"
      end
    end
  end
end
