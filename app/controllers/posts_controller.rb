class PostsController < ApplicationController
  before_action :set_post, only: %i[ show destroy ]

  # GET /posts or /posts.json
  def index
    redirect_to root_path
  end

  # GET /posts/1 or /posts/1.json
  def show
    @show_modal = true

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to root_path, notice: I18n.t('views.posts.post_created') }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { redirect_to root_path, status: :unprocessable_entity, alert: @post.errors.full_messages}
        format.json { render json: @post.errors, status: :unprocessable_entity }
        format.turbo_stream { flash.now[:alert] = @post.errors.full_messages }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    respond_to do |format|
      if @post.user == current_user
        @post.destroy!
        format.html { redirect_to root_path, notice: I18n.t('views.posts.post_destroyed') }
        format.json { head :no_content }
      else
        format.html { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:caption, :longitude, :latitude, 
        :user_id, :allow_comments, :is_story, :show_likes_count, :images, images: [])
    end
end
