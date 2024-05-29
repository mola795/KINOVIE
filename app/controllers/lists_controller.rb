class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @lists = List.all
  end

  def show
    @list = List.includes(:user).find(params[:id])
    if @list.name == 'Watchlist' || @list.name == 'Ratings'
      @list_items = @list.list_items.order(rank: :desc)
    else
      @list_items = @list.list_items.order(:rank)
    end
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(list_params)
    @list.user = current_user
    if @list.save
      update_genres(@list)
      if params[:title_id].present?
        @title = Title.find(params[:title_id])
        ListItem.create(title: @title, list: @list, rank: @list.list_items.count + 1)
      end
      redirect_to @list, notice: 'List created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @list = List.find(params[:id])
    @list_items = @list.list_items.order(:rank)
    if @list.name == 'Watchlist'
      redirect_to @list, alert: 'The Watchlist cannot be renamed.'
    elsif @list.name == 'Ratings'
      redirect_to @list, alert: 'The Ratings list cannot be renamed.'
    else
      @list.genre_connections.build if @list.genre_connections.empty?
    end
  end

  def update
    @list = List.find(params[:id])
    if @list.name == 'Watchlist'
      redirect_to @list, alert: 'The Watchlist cannot be renamed.'
    elsif @list.name == 'Ratings'
      redirect_to @list, alert: 'The Ratings list cannot be renamed.'
    else
      begin
        ActiveRecord::Base.transaction do
          original_list = @list.list_items.order(:rank).to_a
          temp_list = original_list.dup

          @list.update!(list_update_params.except(:list_items_attributes))

          params[:list][:list_items_attributes].each do |id, attributes|
            item_to_move = temp_list.find { |item| item.id == id.to_i }
            new_position = attributes[:new_rank].to_i - 1
            old_position = attributes[:old_rank].to_i - 1

            if old_position != new_position
              temp_list.delete_at(old_position)
              temp_list.insert(new_position, item_to_move)
            end
          end

          temp_list.each_with_index do |item, index|
            item.update!(rank: index + 1)
          end

          update_genres(@list)

          redirect_to @list, notice: 'List was updated and genres were successfully linked.'
        end
      rescue => e
        @list.errors.add(:base, e.message)
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @list = List.find(params[:id])

    if @list.name == 'Watchlist'
      redirect_to lists_path, alert: 'The Watchlist cannot be deleted.'
    elsif @list.name == 'Ratings'
      redirect_to lists_path, alert: 'The Ratings list cannot be deleted.'
    else
      @list.destroy
      redirect_to lists_path, notice: 'List was deleted.', status: :see_other
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :description, :status, genre_ids: [])
  end

  def list_update_params
    params.require(:list).permit(:name, :description, :status, genre_connections_attributes: [:id, :genre_id, :_destroy], list_items_attributes: [:id, :old_rank, :new_rank], genre_ids: [])
  end

  def update_genres(list)
    list.genre_connections.destroy_all
    if params[:list][:genre_ids].present?
      params[:list][:genre_ids].reject(&:blank?).each do |genre_id|
        list.genre_connections.create!(genre_id: genre_id)
      end
    end
    flash[:notice] = "Genres were successfully linked with the list."
  end
end
