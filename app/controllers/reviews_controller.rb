class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update]

  def create
    @title = Title.find(params[:title_id])
    @review = Review.new(review_params)
    @review.user = current_user
    @review.title = @title
    if @review.save
      redirect_to @title
    else
      render :new
    end
  end

  def update
    @title = Title.find(params[:title_id])
    @review = Review.find(params[:id])
    if @review.update(review_params)
      redirect_to @title
    else
      render :edit
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
