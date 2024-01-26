require 'system_helper'
require './spec/helpers/system_follows_helper'

RSpec.describe 'Follows feature', type: :system do
  include SystemFollowsHelper
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  describe 'user' do
    it 'follows another user' do
      # login user and visit another's user profile page
      login_and_redirect(@user2, user_path(@user))

      test_follow
    end

    it 'unfollows another user' do
      # follow user
      @user2.follow!(@user)

      # login user and visit another's user profile page
      login_and_redirect(@user2, user_path(@user))

      test_unfollow
    end

    it 'send follow request to private user' do
      # login user and visit another's user profile page
      login_and_redirect(@user, user_path(@user2))

      # assert no unfollow btn visible, do follow, btn follow changed to unfollow
      test_follow_private
    end

    it 'cancels follow request' do
      @user.follow!(@user2)

      # login user and visit another's user profile page
      login_and_redirect(@user, user_path(@user2))

      test_cancel_follow_request
    end

    it 'sees follow requests' do
      user3 = create(:user)
      user4 = create(:user)
      @user.follow!(@user2)
      user3.follow!(@user2)
      user4.follow!(@user2)

      # login user
      login_and_visit_root(@user2)

      # open dropdown and assert followers that requested
      find('#user-navbar .follows-dropdown').click
      expect(all('#follows-cnt .follow-cnt .follower-username').map(&:text))
        .to eq(@user2.follow_requests.map(&:follower).map(&:username))
    end

    it 'accepts follow request' do
      @user.follow!(@user2)

      # login user and visit another's user profile page
      login_and_visit_root(@user2)

      # open dropdown and accept request
      expect(find('#follows-count').text).to eq '1'
      find('#user-navbar .follows-dropdown').click
      first('#follows-cnt .follow-cnt .btn-accept-request').click
      wait_for_turbo
      expect(find('#follows-count').text).to eq '0'

      # assert follower accepted
      expect(@user2.followers.reload).to eq [@user]
    end


    it 'decline follow request' do
      @user.follow!(@user2)

      # login user and visit another's user profile page
      login_and_visit_root(@user2)

      # open dropdown and accept request
      expect(find('#follows-count').text).to eq '1'
      find('#user-navbar .follows-dropdown').click
      first('#follows-cnt .follow-cnt .btn-decline-request').click
      wait_for_turbo
      expect(find('#follows-count').text).to eq '0'

      # assert follower accepted
      expect(@user2.followers.reload).to eq []
      expect(@user2.follow_requests.reload).to eq []
    end
    
  end
  
end