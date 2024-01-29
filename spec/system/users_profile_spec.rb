require 'system_helper'
require './spec/helpers/system_posts_helper'
require './spec/helpers/search_helper'

RSpec.describe 'Users profile page', type: :system do
  include SystemPostsHelper
  include SearchHelper
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  def do_search(q)
    find('#search_query').set q
    wait_for_turbo
    sleep 0.5 # delay on change
  end

  describe 'user' do
    context 'show profile page' do
      it 'can see someones profile page' do
        @user2.update(private: false)
        4.times { create(:post, user: @user2) }
        login_and_redirect(@user, user_path(@user2))

        # can see profile info
        assert_profile_info_visible(@user2)

        # can see posts
        expect(all('.profile-posts-cnt .profile-post').count).to eq @user2.posts.count
      end

      it 'cannot see someones posts on private user if not followed' do
        4.times { create(:post, user: @user2) }
        login_and_redirect(@user, user_path(@user2))

        # can see profile info
        assert_profile_info_visible(@user2)

        # can't see posts
        assert_css '.profile-private-cnt'
        within '.profile-private-cnt' do
          assert_content I18n.t('views.users.account_private_info')
          assert_content I18n.t('views.users.account_private_follow_info')
        end
      end

      it 'cannot see someones post on private user if not followed when href entered manually' do
        post1 = create(:post, user: @user)
        post2 = create(:post, user: @user2)
        login_and_visit_root(@user)
        page.execute_script("document.getElementsByClassName('show-post-modal')[0].href = '#{post_path(post2)}'")
        within_first_post { first('.show-post-modal .post-image').click }
        assert_flash I18n.t('no_access')
      end

      it "can see private user's post when followed" do
        # follow user
        @user.follow!(@user2)
        @user2.follow_requests.each(&:accept!)

        4.times { create(:post, user: @user2) }
        login_and_redirect(@user, user_path(@user2))

        # can see posts
        expect(all('.profile-posts-cnt .profile-post').count).to eq @user2.posts.count
      end

      it 'sees info when no posts' do
        login_and_redirect(@user, user_path(@user))

        # can't see posts - no posts yet
        assert_css '.no-posts-info'
        within '.no-posts-info' do
          assert_content I18n.t('views.posts.no_posts')
        end
      end

      it 'sees his posts count' do
        login_and_redirect(@user, user_path(@user))

        # assert no posts yet
        expect(find('.posts-count').text).to eq I18n.t('views.users.posts_x', count: 0)

        # create 7 posts, visit page, assert
        7.times { create(:post, user: @user) }
        visit user_path(@user)
        expect(find('.posts-count').text).to eq I18n.t('views.users.posts_x', count: 7)
      end

      it "sees post's comments count if post allows commenting" do
        create(:post, user: @user, allow_comments: true)
        login_and_redirect(@user, user_path(@user))

        first('.profile-post').hover
        within first('.profile-post') { assert_css('.profile-post-comments') }
      end

      it "cannot see post's comments count if post doesn't allow commenting" do
        create(:post, user: @user, allow_comments: false)
        login_and_redirect(@user, user_path(@user))

        first('.profile-post').hover
        within first('.profile-post') { assert_no_css('.profile-post-comments') }
      end

      it "sees post's likes count if post allows it" do
        user = create(:user, private: false)
        create(:post, user: user, show_likes_count: true)
        login_and_redirect(@user, user_path(user))

        first('.profile-post').hover
        within first('.profile-post') { assert_css('.profile-post-likes') }
      end

      it "cannot see post's likes count if post doesn't allow it" do
        user = create(:user, private: false)
        create(:post, user: user, show_likes_count: false)
        login_and_redirect(@user, user_path(user))

        first('.profile-post').hover
        within first('.profile-post') { assert_no_css('.profile-post-likes') }
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

      it 'tries by search results username' do
        create_post_and_comments
        login_and_visit_root(@user)
        find('#search_query').click
        do_search(@user.username)
        first('#search_results .username').click

        assert_current_path user_path(@user)
      end

      it 'tries by search results profile picture' do
        create_post_and_comments
        login_and_visit_root(@user)
        find('#search_query').click
        do_search(@user.username)
        first('#search_results .pp-img').click

        assert_current_path user_path(@user)
      end

      it 'tries by story username' do
        user = create(:user)
        create(:story, user: @user)
        user.follow!(@user)
        login_and_visit_root(@user)

        first('.stories-card .username').click
        assert_current_path user_path(@user)
      end
    end

    context 'search' do
      it 'can be find users' do
        login_and_visit_root(@user)
        
        find('#search_query').click
        test_search do |d|
          do_search(d[0])
          if d[1].any?
            expected = d[1].map(&:username)
            expect(all('#search_results .username').map(&:text).sort).to eq expected.sort
          else
            within('#search_results') { assert_content I18n.t('no_results')}
          end
        end
      end
    end
  end

  
  private

  def create_post_and_likes
    post = create(:post, user: @user)
    user2 = create(:user)
    user3 = create(:user)
    create(:like, user: @user, post: post)
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