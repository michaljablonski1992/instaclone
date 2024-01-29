class CommentsController < ApplicationController
  before_action :set_post, only: [:create]
  def create 
    respond_to do |format|
      if @post.allow_comments?
        @comment = @post.comments.create(user: current_user, body: params[:comment_body])
        format.turbo_stream
      else
        format.html { redirect_to root_path, status: :unprocessable_entity }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def destroy 
    @comment = Comment.find(params[:id])
    if(@comment.user == current_user)
      @comment.destroy

      respond_to do |format|
        format.turbo_stream { @post = @comment.post }
      end
    end
  end


  private
  
  def set_post 
    @post = Post.find(params[:post_id])
  end
end