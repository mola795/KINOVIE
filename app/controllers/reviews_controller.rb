class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:create]


  def create
    @title = Title.find(params[:title_id])
    @review = Review.new(review_params)
    @review.user = current_user
    @review.title = @title
    @review.save
    redirect_to @title
  end

  def update
    @title = Title.find(params[:title_id])
    @review = Review.find(params[:id])
    @review.update(review_params)
    redirect_to @title
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
