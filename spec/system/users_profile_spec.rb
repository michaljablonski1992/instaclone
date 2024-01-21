require 'system_helper'
require './spec/helpers/system_posts_helper'

RSpec.describe 'Users profile page', type: :system do
  include SystemPostsHelper
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  describe 'user' do
    context 'show profile page' do
      it 'can see someones profile page' do
        @user2.update(private: false)
        4.times { create(:post, user: @user2) }
        login_as @user
        visit user_path(@user2)

        # can see profile info
        assert_profile_info_visible(@user2)

        # can see posts
        expect(all('.profile-posts-cnt .profile-post').count).to eq @user2.posts.count
      end

      it 'cannot see someones posts on private user if not followed' do
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

      it 'cannot see someones post on private user if not followed when entered manually' do
        post = create(:post, user: @user2)
        login_as @user
        visit post_path(post)
        assert_current_path root_path
      end

      it "can see private user's post when followed" do
        # follow user
        @user.follow!(@user2)
        @user2.follow_requests.each(&:accept!)

        4.times { create(:post, user: @user2) }
        login_as @user
        visit user_path(@user2)

        # can see posts
        expect(all('.profile-posts-cnt .profile-post').count).to eq @user2.posts.count
      end

      it 'can see someones post on private user if followed when entered manually' do
        # follow user
        @user.follow!(@user2)
        @user2.follow_requests.each(&:accept!)

        # create post
        post = create(:post, user: @user2)

        # login and see
        login_as @user
        visit post_path(post)
        assert_current_path post_path(post)
      end

      it 'sees info when no posts' do
        login_as @user
        visit user_path(@user)

        # can't see posts - no posts yet
        assert_css '.no-posts-info'
        within '.no-posts-info' do
          assert_content I18n.t('views.posts.no_posts')
        end
      end

      it 'sees his posts count' do
        login_as @user
        visit user_path(@user)

        # assert no posts yet
        expect(find('.posts-count').text).to eq I18n.t('views.users.posts_x', count: 0)

        # create 7 posts, visit page, assert
        7.times { create(:post, user: @user) }
        visit user_path(@user)
        expect(find('.posts-count').text).to eq I18n.t('views.users.posts_x', count: 7)
      end
    end

    context 'reach profile page' do
      it 'tries by navbar - own profile page' do
        login_and_visit_root(@user)
        find('.profile-dropdown').click
        find('.profile-menu .goto-profile').click
        assert_current_path user_path(@user)
      end

      it "tries by posts's username" do
        post = create(:post, user: @user)
        login_and_visit_root(@user)
        within_first_post { find('.post-username-link').click }
        assert_current_path user_path(@user)
      end

      it "tries by posts's user's profile picture" do
        post = create(:post, user: @user)
        login_and_visit_root(@user)
        within_first_post { find('.card-header .pp-img').click }
        assert_current_path user_path(@user)
      end

      it "tries by liker's username" do
        create_post_and_likes
        login_and_visit_root(@user)
        within_first_post { find('.post-likes').click }
        within('.likers-modal') { first('.username').click }
        assert_current_path user_path(@user)
      end

      it "tries by liker's profile picture" do
        create_post_and_likes
        login_and_visit_root(@user)
        within_first_post { find('.post-likes').click }
        within('.likers-modal') { first('.pp-img').click }
        assert_current_path user_path(@user)
      end

      it "tries by commentator's username" do
        create_post_and_comments
        login_and_visit_root(@user)
        within_first_post { find('.show-comments-btn').click }
        within('.comments-modal') { first('.username').click }
        assert_current_path user_path(@user)
      end

      it "tries by commentator's profile picture" do
        create_post_and_comments
        login_and_visit_root(@user)
        within_first_post { find('.show-comments-btn').click }
        within('.comments-modal') { first('.pp-img').click }
        assert_current_path user_path(@user)
      end

      it "tries by top comment's username" do
        create_post_and_comments
        login_and_visit_root(@user)
        within_first_post { first('.top-comment .username').click }
        assert_current_path user_path(@user)
      end
    end
  end

  
  private

  def create_post_and_likes
    post = create(:post, user: @user)
    user2 = create(:user)
    user3 = create(:user)
    create(:like, user: @user, post: post)
    create(:like, user: user3, post: post)
  end

  def create_post_and_comments
    post = create(:post, user: @user)
    user2 = create(:user)
    user3 = create(:user)
    create(:comment, user: @user, post: post)
    create(:comment, user: user2, post: post)
  end

  def assert_profile_info_visible(user)
    expect(find('.username').text).to eq user.username
    expect(find('.full_name').text).to eq user.full_name
    expect(find('.posts-count').text).to eq I18n.t('views.users.posts_x', count: user.posts.count)
    expect(find('.followers-count').text).to eq I18n.t('views.users.followers_x', count: 0)
    expect(find('.followings-count').text).to eq I18n.t('views.users.followings_x', count: 0)
    expect(find('.bio').text).to eq user.bio
  end
  
end