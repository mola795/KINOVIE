class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]


  def create
    @title = Title.find(params[:title_id])
    @review = @title.reviews.new(review_params)
    @review.user = current_user

    redirect_to @title
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
