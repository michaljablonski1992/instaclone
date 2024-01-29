class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    if params[:search_query].present?
      @users = User.search(params[:search_query])
    else
      @users = []
    end

    if turbo_frame_request?
      render partial: 'layouts/navbar/search_results', locals: { users: @users }
    end
  end

  def show

  end

  private
  def set_user
    @user = User.active.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end