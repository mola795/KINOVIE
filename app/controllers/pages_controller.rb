class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @titles = Title.all.select { |title| title.name.split.size <= 3 }
  end
end
