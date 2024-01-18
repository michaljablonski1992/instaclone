require 'system_helper'

RSpec.describe 'Users profile page', type: :system do
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  it 'gives ability to see someones profile page' do
    @user2.update(private: false)
    4.times { create(:post, user: @user2) }
    login_as @user
    visit user_path(@user2)

    # can see profile info
    assert_profile_info_visible(@user2)

    # can see posts
    expect(all('.profile-posts-cnt .profile-post').count).to eq @user2.posts.count
  end

  it 'gives prevents to see post on private user if not followed' do
    4.times { create(:post, user: @user2) }
    login_as @user
    visit user_path(@user2)

    # can see profile info
    assert_profile_info_visible(@user2)

    # can't see posts
    assert_css '.profile-private-cnt'
    within '.profile-private-cnt' do
      assert_content I18n.t('views.users.account_private_info')
      assert_content I18n.t('views.users.account_private_follow_info')
    end
  end

  
  private

  def assert_profile_info_visible(user)
    expect(find('.username').text).to eq user.username
    expect(find('.full_name').text).to eq user.full_name
    expect(find('.posts-count').text).to eq I18n.t('views.users.posts_x', count: user.posts.count)
    ## TODO: change me after followers/followings implementation
    expect(find('.followers-count').text).to eq I18n.t('views.users.followers_x', count: 100)
    expect(find('.followings-count').text).to eq I18n.t('views.users.followings_x', count: 1)
    expect(find('.bio').text).to eq user.bio
  end
  
end