class ListsController < ApplicationController

  def index
    @lists = List.all
  end

  def show
    @list = List.find(params[:id])
    @list_items = @list.list_items
  end

  def new
  @list = List.new
  end

  def create
  @list = List.new(list_params)
  @list.user = current_user
    if @list.save
      redirect_to @list, notice: 'List was created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :description, :status)
  end

end
