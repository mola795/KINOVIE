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

  def like_review
    @review_to_like = Review.find(params[:review])
    current_user.favorite(@review_to_like) if @review_to_like
  end

  def unlike_review
    @review_to_unlike = Review.find(params[:review])
    current_user.unfavorite(@review_to_unlike) if @review_to_unlike
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
