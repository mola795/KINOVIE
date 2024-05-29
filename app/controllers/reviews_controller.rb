class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def create
    @title = Title.find(params[:title_id])
    @review = Review.new(review_params)
    @review.user = current_user
    @review.title = @title
    if @review.save
      add_to_ratings_list_and_remove_from_watchlist(@title)
      redirect_to @title
    else
      render :new
    end
  end

  def update
    @title = Title.find(params[:title_id])
    @review = Review.find(params[:id])
    if @review.update(review_params)
      add_to_ratings_list_and_remove_from_watchlist(@title)
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

  def add_to_ratings_list_and_remove_from_watchlist(title)
    # Add to Ratings list
    ratings_list = current_user.lists.find_or_create_by(name: 'Ratings') do |list|
      list.description = 'All the titles I have rated.'
      list.status = 'Private'
    end
    ratings_list_item = ratings_list.list_items.find_or_initialize_by(title: title)
    ratings_list_item.rank = ratings_list.list_items.count + 1 unless ratings_list_item.persisted?
    ratings_list_item.save unless ratings_list_item.persisted?

    # Remove from Watchlist
    watchlist = current_user.lists.find_by(name: 'Watchlist')
    if watchlist
      watchlist_item = watchlist.list_items.find_by(title: title)
      watchlist_item.destroy if watchlist_item
    end
  end

  def remove_from_ratings_list(title)
    list = current_user.lists.find_by(name: 'Ratings')
    return unless list

    list_item = list.list_items.find_by(title: title)
    list_item.destroy if list_item
  end
end
