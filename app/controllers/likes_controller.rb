class LikesController < ApplicationController
  before_action :set_post

  def toggle_like
    @like = @post.likes.find_by(user: current_user)

    if @like.present?
      @like.destroy
    else
      @post.likes.create(user: current_user)
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private
  
  def set_post
    @post = Post.find(params[:post_id])
  end
end