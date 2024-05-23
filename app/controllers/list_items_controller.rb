class ListItemsController < ApplicationController

  def new
    @list_item = ListItem.new
  end

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

  def destroy
    @list_item = ListItem.find(params[:id])
    @list_item.destroy
    redirect_to list_path(@list_item.list)
  end

  private

  def list_item_params
    params.require(:list_item).permit(:list_id)
  end

end
