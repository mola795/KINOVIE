class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @titles = Title.all.select { |title| title.name.split.size <= 3 }
    @lists = List.includes(:user).all

    return unless user_signed_in?

    @friends_activity = current_user.friends_activity.reverse

    @all_activity = current_user.all_activity.reverse
  end


end
