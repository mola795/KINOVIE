class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @genres = Genre.where.not(cover_url: nil)
                   .where.not(name: ["Animation", "TV Movie", "Kids", "Documentary", "War"])
                   .sample(12)
    @lists = List.includes(:user).all
  end
end
