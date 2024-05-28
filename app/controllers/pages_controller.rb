class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @titles = Title.all.select { |title| title.name.split.size <= 3 }
    @lists = List.includes(:user).all
  end

  # def profile
  #   @user = current_user
  #   # @lists = @user.lists.where.not(status: 'Private').order(:created_at)
  #   # @private_lists = @user.lists.where(status: 'Private').where.not(name: 'Watchlist').order(:created_at)
  #   # @watchlist = @user.lists.find_by(name: 'Watchlist')
  #   @lists = @user.lists.order(:created_at)
  #   @follows = @user.follows
  #   @list_activity = @user.activity.reverse.map do |list|
  #     list.activity_string
  #   end

  #   render 'users/show'
  # end
end
