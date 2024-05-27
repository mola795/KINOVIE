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

    if @list_item.persisted?
      redirect_to title_path(@title), notice: 'Title is already in your Watchlist.'
    elsif @list_item.save
      redirect_to title_path(@title), notice: 'Title was added to your Watchlist.'
    else
      redirect_to title_path(@title), alert: "#{@list_item.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @list_item = ListItem.find(params[:id])
    @list_item.destroy
    redirect_to list_path(@list_item.list), notice: 'Title was removed from the list.', status: :see_other
  end

  private

  def list_item_params
    params.require(:list_item).permit(:list_id, :title_id, :comment)
  end
end
