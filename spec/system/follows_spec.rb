require 'system_helper'

RSpec.describe 'Follows feature', type: :system do
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  describe 'user' do
    it 'follows another user' do
      # login user and visit another's user profile page
      login_as @user2
      visit user_path(@user)

      # assert no unfollow btn visible, do follow, btn follow changed to unfollow
      assert_no_css('.unfollow-btn')
      find('.follow-btn').click
      assert_no_css('.follow-btn')
      assert_css('.unfollow-btn')
    end

    it 'unfollows another user' do
      # follow user
      @user2.follow!(@user)

      # login user and visit another's user profile page
      login_as @user2
      visit user_path(@user)

      # assert no follow btn visible, do unfollow, btn unfollow changed to follow
      assert_no_css('.follow-btn')
      find('.unfollow-btn').click
      assert_no_css('.unfollow-btn')
      assert_css('.follow-btn')
    end

    it 'send follow request to private user' do
      # login user and visit another's user profile page
      login_as @user
      visit user_path(@user2)

      # assert no unfollow btn visible, do follow, btn follow changed to unfollow
      assert_no_css('.cancel-request-btn')
      find('.follow-btn').click
      assert_no_css('.follow-btn')
      assert_css('.cancel-request-btn')
    end

    it 'cancels follow request' do
      @user.follow!(@user2)

      # login user and visit another's user profile page
      login_as @user
      visit user_path(@user2)

      # assert no unfollow btn visible, do follow, btn follow changed to unfollow
      assert_no_css('.follow-btn')
      find('.cancel-request-btn').click
      assert_no_css('.cancel-request-btn')
      assert_css('.follow-btn')
    end

    it 'sees follow requests' do
      user3 = create(:user)
      user4 = create(:user)
      @user.follow!(@user2)
      user3.follow!(@user2)
      user4.follow!(@user2)

      # login user
      login_as @user2
      visit root_path

      # open dropdown and assert followers that requested
      find('#user-navbar .follows-dropdown').click
      expect(all('#follows-cnt .follow-cnt .follower-username').map(&:text))
        .to eq(@user2.follow_requests.map(&:follower).map(&:username))
    end

    it 'accepts follow request' do
      @user.follow!(@user2)

      # login user and visit another's user profile page
      login_as @user2
      visit root_path

      # open dropdown and accept request
      find('#user-navbar .follows-dropdown').click
      first('#follows-cnt .follow-cnt .btn-accept-request').click
      wait_for_turbo

      # assert follower accepted
      expect(@user2.followers.reload).to eq [@user]
    end


    it 'decline follow request' do
      @user.follow!(@user2)

      # login user and visit another's user profile page
      login_as @user2
      visit root_path

      # open dropdown and accept request
      find('#user-navbar .follows-dropdown').click
      first('#follows-cnt .follow-cnt .btn-decline-request').click
      wait_for_turbo

      # assert follower accepted
      expect(@user2.followers.reload).to eq []
      expect(@user2.follow_requests.reload).to eq []
    end
    
  end

  
  private
  
end