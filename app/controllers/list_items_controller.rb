class ListItemsController < ApplicationController

  def create
    @title = Title.find(params[:title_id])
    @list_item = ListItem.new(list_item_params)
    @list_item.title = @title
    if @list_item.save
      redirect_to title_path(@title), notice: "Added to #{@list_item.list.name}."
    else
      render "titles/show", status: :unprocessable_entity
    end
  end

  private

  def list_item_params
    params.require(:list_item).permit(:list_id)
  end

end
