module FeedsHelper
  def create_feeds(user)
    ## create posts users and posts
    # 2 my posts
    2.times { create(:post, user: user) }
    # 2 @user_following's posts - following
    @user_following = create(:user, private: false)
    2.times { create(:post, user: @user_following) }
    user.follow!(@user_following)
    # 3 user3's posts - not following - should not be shown
    user3 = create(:user)
    2.times { create(:post, user: user3) }
    # 1 user4's posts - follow request sent but not accepted yet - should not be shown
    user3 = create(:user)
    2.times { create(:post, user: user3) }
    user.follow!(user3)
  end
end