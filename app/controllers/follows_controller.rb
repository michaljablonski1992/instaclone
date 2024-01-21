class FollowsController < ApplicationController
  include DomIdsHelper
  before_action :set_user, only: [:follow, :unfollow, :cancel_request]
  before_action :set_follow_req, only: [:accept_follow, :decline_follow]

  ## follows
  def follow
    current_user.follow!(@user)
    follows_actions_respond
  end

  def unfollow
    current_user.unfollow!(@user)
    follows_actions_respond
  end

  ## requests
  def cancel_request
    current_user.cancel_request!(@user)
    follows_actions_respond
  end

  def accept_follow
    @follow_req.accept!
    requests_actions_respond
  end
  def decline_follow
    @follow_req.decline!
    requests_actions_respond
  end


  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_follow_req
    @follow_req = current_user.follow_requests.find(params[:follow_id])
  end

  def follows_actions_respond
    content_id = params[:content_id]
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          content_id,
          **partial_data_from_content_id(content_id)
        )
      end
    end
  end

  def requests_actions_respond
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'follows-cnt',
          partial: 'layouts/navbar/follows_cnt_content'
        )
      end
    end
  end

end