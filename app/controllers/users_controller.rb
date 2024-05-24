class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @lists = @user.lists.where.not(status: 'Private').order(:created_at)
    @private_lists = @user.lists.where(status: 'Private').order(:created_at)
  end
end
