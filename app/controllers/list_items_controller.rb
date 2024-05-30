class ListItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    @title = Title.find(params[:title_id])
    @list = current_user.lists.find(params[:list_item][:list_id])
    @list_item = @list.list_items.new(title: @title, rank: @list.list_items.count + 1)

    if @list_item.save
      redirect_to title_path(@title), notice: 'Title was added to the list.'
    else
      redirect_to title_path(@title), alert: "#{@list_item.errors.full_messages.join(', ')}"
    end
  end

  def add_to_watchlist
    @title = Title.find(params[:title_id])
    @list = current_user.lists.find_or_create_by(name: 'Watchlist') do |list|
      list.description = 'Watchlist'
      list.status = 'Private'
    end

    @list_item = @list.list_items.find_or_initialize_by(title: @title)
    @list_item.rank = @list.list_items.count + 1 unless @list_item.persisted?

    respond_to do |format|
      if @list_item.save
        format.html { redirect_back fallback_location: root_path, notice: 'Title was added to your Watchlist.' }
        format.js
      else
        format.html { redirect_back fallback_location: root_path, alert: "#{@list_item.errors.full_messages.join(', ')}" }
      end
    end
  end

  def add_to_ratings_list
    @title = Title.find(params[:title_id])
    @list = current_user.lists.find_or_create_by(name: 'Ratings') do |list|
      list.description = 'A list of all titles I have rated'
      list.status = 'Private'
    end

    unless @list.list_items.exists?(title_id: @title.id)
      @list_item = @list.list_items.create!(title: @title, rank: @list.list_items.count + 1)
    end

    redirect_to title_path(@title), notice: 'Title was added to your Ratings list.'
  end

  def destroy
    @list_item = ListItem.find(params[:id])
    if @list_item.list.name == 'Ratings'
      redirect_to list_path(@list_item.list), alert: 'You cannot remove items from the Ratings list manually.', status: :see_other
    else
      @list_item.destroy
      redirect_to list_path(@list_item.list), notice: 'Title was removed from the list.', status: :see_other
    end
  end

  private

  def list_item_params
    params.require(:list_item).permit(:list_id, :title_id, :comment)
  end
end
