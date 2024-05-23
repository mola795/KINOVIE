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
end
