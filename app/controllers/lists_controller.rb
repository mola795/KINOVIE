class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @lists = List.all
    @lists = @lists.where.not(status: 'Private')
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

  def edit
    @list = List.find(params[:id])
    if @list.name == 'Watchlist'
      redirect_to @list, alert: 'The Watchlist cannot be renamed.'
    else
      @list.genre_connections.build if @list.genre_connections.empty? # Ensure form builds fields for genres if none exist
    end
  end

  def update
    @list = List.find(params[:id])
    if @list.name == 'Watchlist'
      redirect_to @list, alert: 'The Watchlist cannot be renamed.'
    else
      if @list.update(list_update_params)
        redirect_to @list, notice: 'List was updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @list = List.find(params[:id])

    if @list.name == 'Watchlist'
      redirect_to lists_path, alert: 'The Watchlist cannot be deleted.'
    else
      @list.destroy
      redirect_to lists_path, notice: 'List was deleted.', status: :see_other
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :description, :status)
  end

  def list_update_params
    params.require(:list).permit(:name, :description, :status, genre_connections_attributes: [:id, :genre_id, :_destroy])
  end
end
