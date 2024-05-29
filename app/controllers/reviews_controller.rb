class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def create
    @title = Title.find(params[:title_id])
    @review = Review.new(review_params)
    @review.user = current_user
    @review.title = @title
    if @review.save
      add_to_ratings_list(@title)
      redirect_to @title
    else
      render :new
    end
  end

  def update
    @title = Title.find(params[:title_id])
    @review = Review.find(params[:id])
    if @review.update(review_params)
      add_to_ratings_list(@title)
      redirect_to @title
    else
      render :edit
    end
  end

  def destroy
    @review = Review.find(params[:id])
    if @review.user == current_user
      remove_from_ratings_list(@review.title)
      @review.destroy
      redirect_to @review.title, notice: 'Review was successfully deleted.'
    else
      redirect_to @review.title, alert: 'You can only delete your own reviews.'
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def add_to_ratings_list(title)
    list = current_user.lists.find_or_create_by(name: 'Ratings') do |list|
      list.description = 'All the titles I have rated.'
      list.status = 'Private'
    end

    list_item = list.list_items.find_or_initialize_by(title: title)
    list_item.rank = list.list_items.count + 1 unless list_item.persisted?
    list_item.save unless list_item.persisted?
  end

  def remove_from_ratings_list(title)
    list = current_user.lists.find_by(name: 'Ratings')
    return unless list

    list_item = list.list_items.find_by(title: title)
    list_item.destroy if list_item
  end
end
