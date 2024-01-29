require 'system_helper'
require './spec/helpers/system_posts_helper'
require './spec/helpers/system_follows_helper'
require './spec/helpers/feeds_helper'

RSpec.describe 'Posts', type: :system do
  include SystemPostsHelper
  include SystemFollowsHelper
  include FeedsHelper
  include DomIdsHelper
  before(:each) { @user = create(:user) }

  def fill_post
    within '#postModal' do
      page.attach_file(Rails.root.join('spec/fixtures/image.png')) do
        find('.filepond--drop-label').click
      end
      find('#post_caption').set 'Example caption'
    end
  end

  def do_location_test(confirm: true, location: nil, exp_longitude: nil, exp_latitude: nil, exp_location_provided: false)
    # sign in, visit root
    login_and_visit_root(@user)
    # click create post -> modal
    find('#create-post').click
    expect(page).to have_selector '#postModal.show'

    # assert not location set, go to location map
    within '#postModal' do
      expect(find('.location').text).to eq I18n.t('views.post_modal.no_location_set')
      sleep 0.3
      find('#set-location-btn').click
    end

    # within map do not set anything and click confirm
    expect(page).to have_selector '#mapModal.show'
    within '#mapModal' do
      expect(page).to have_selector '#map.leaflet-container'
      expect(page).to have_selector '#confirm-location'
      if location.present? # set location
        find('.leaflet-control-geocoder-form > input').set location
        expect(page).to have_selector '.leaflet-control-geocoder-alternatives'
        first('.leaflet-control-geocoder-alternatives > li').click
      end
      # confirm or go back
      confirm ? find('#confirm-location').click : find('.back-btn').click
    end
    expect(page).to have_selector '#postModal.show'

    # create post, test if is OK in db
    fill_post
    click_on 'Post'
    wait_for_turbo
    post = Post.last
    expect(post.longitude).to eq exp_longitude
    expect(post.latitude).to eq exp_latitude
    expect(post.location_provided?).to be exp_location_provided
  end

  describe 'user' do
    it 'sees posts' do
      create_feeds(@user)

      # sign in, visit root
      login_and_visit_root(@user)
      within '#posts-list' do
        expect(all('.post-card').count).to eq 4
        expect(all('.post-card .post-username-link').map(&:text).uniq.sort).to eq [@user.username, @user_following.username].sort
      end
    end

    it 'submits invalid post' do
      # sign in, visit root
      login_and_visit_root(@user)
      # click create post -> modal
      find('#create-post').click
      expect(page).to have_selector '#postModal.show'

      # click post, assert errors
      within('#postModal') { click_on 'Post' }
      assert_flash "Images can't be blank"
      assert_flash "Caption can't be blank"
    end

    it "submits invalid file type for post's image" do
      # sign in, visit root
      login_and_visit_root(@user)
      # click create post -> modal
      find('#create-post').click
      expect(page).to have_selector '#postModal.show'

      # click post, assert errors
      within('#postModal') do 
        page.attach_file(Rails.root.join('spec/fixtures/file.txt')) do
          find('.filepond--drop-label').click
        end
        expect(first('.filepond--file')).to have_content('File is of invalid type')

        click_on 'Post'
      end
      assert_flash "Images can't be blank"
    end

    it 'creates post' do
      # no posts yet
      Post.destroy_all

      # sign in, visit root
      login_and_visit_root(@user)

      # assert no posts yet
      expect(all('#posts-list > .post-cnt').count).to be 0

      # click create post -> modal
      find('#create-post').click
      expect(page).to have_selector '#postModal.show'

      fill_post
      click_on 'Post'

      # assert post has been made
      expect(page).to_not have_selector '#postModal.show'
      assert_flash 'Post was successfully created'
      expect(Post.count).to be 1
      expect(all('#posts-list > .post-cnt').count).to be 1
      post = Post.last
      expect(post.caption).to eq('Example caption')
      expect(post.images.count).to be 1
    end

    it 'likes the post' do
      post = create(:post)
      user = post.user
      # sign in, visit root
      login_and_visit_root(user)

      # expect no likes yet - db
      expect(post.likes.count).to eq 0
      expect(post.likers.count).to eq 0

      ## like the post
      # assert within post
      within_first_post do
        # no likes yet
        expect(find('.post-likes').text).to eq I18n.t('views.post_card.likes_x', count: 0)

        # like the post
        find('.like-btn').click
        wait_for_turbo

        # expect the post is liked
        expect(find('.post-likes').text).to eq I18n.t('views.post_card.likes_x', count: 1)
      end

      # expect post is liked by 'liker'
      expect(post.likes.count).to eq 1
      expect(post.likers.count).to eq 1
      expect(post.likers.first).to eq user
    end

    it 'unlikes the post' do
      post = create(:post)
      user = post.user
      like = create(:like, post: post, user: user)
      # sign in, visit root
      login_and_visit_root(user)

      # expect post is liked by 'liker'
      expect(post.likes.count).to eq 1
      expect(post.likers.count).to eq 1
      expect(post.likers.first).to eq user

      ## unlike the post
      within_first_post do
        # unlike the post
        find('.like-btn').click
        wait_for_turbo

        # expect the post is unliked
        expect(find('.post-likes').text).to eq I18n.t('views.post_card.likes_x', count: 0)
      end

      # expect post is unliked by 'liker'
      expect(post.likes.count).to eq 0
      expect(post.likers.count).to eq 0
    end

    it 'sees the likers list' do
      # create records
      post = create(:post)
      user = post.user
      user2 = create(:user)
      user3 = create(:user)
      create(:like, post: post, user: user)
      create(:like, post: post, user: user3)
      # sign in, visit root
      login_and_visit_root(user)
      within_first_post { find('.post-likes').click }
      within '.likers-modal' do
        expect(all('.username').map(&:text)).to eq [user.username, user3.username]
      end
    end

    it 'can use follow feature from likers modal - follow private user' do
      # create records
      post = create(:post)
      user = post.user
      user2 = create(:user)
      user3 = create(:user)
      create(:like, post: post, user: user)
      create(:like, post: post, user: user3)
      # sign in, visit root
      login_and_visit_root(user)
      within_first_post { find('.post-likes').click }

      test_follow_private("##{liker_id(user3)}")
    end

    it 'can use follow feature from likers modal - follow non-private user' do
      # create records
      post = create(:post)
      user = post.user
      user2 = create(:user)
      user3 = create(:user, private: false)
      create(:like, post: post, user: user)
      create(:like, post: post, user: user3)
      # sign in, visit root
      login_and_visit_root(user)
      within_first_post { find('.post-likes').click }

      test_follow("##{liker_id(user3)}")
    end

    it 'adds comment' do
      comment_body = 'Example comment test'
      post = create(:post)
      user = post.user
      # sign in, visit root
      login_and_visit_root(user)

      # assert no comments yet
      expect(post.comments.count).to eq 0

      # comment
      within_first_post do
        # assert no comments
        assert_no_css '.view-all-comments'
        assert_no_css '.top-comment'
        # assert no commentators
        find('.show-comments-btn').click
        assert_css('.comments-modal')
        within('.comments-modal') do
          assert_css('.no-comments-msg')
          sleep 0.3
          click_button('Close', class: 'btn-close')
        end

        ## add comment
        find('.comment-input').set comment_body
        find('.post-btn').click
        wait_for_turbo

        # assert comment added
        assert_css('.view-all-comments', text: I18n.t('views.post_card.view_all_comments', count: 1))
        assert_css('.top-comment', text: "#{user.username} #{comment_body}")
        # show commentators in 2 ways
        ['.show-comments-btn', '.view-all-comments'].each do |klass|
          find(klass).click
          expect(all('.modal-comment-cnt').count).to eq 1
          within '.modal-comment-cnt' do
            expect(find('.comment-body').text).to eq comment_body
            expect(find('.comment-username').text).to eq user.username
          end
          sleep 0.3
          click_button('Close', class: 'btn-close')
        end
      end
    end

    it 'deletes his own comment' do
      # comments usernames and bodies
      mapped_comments = -> {
        all('.modal-comment-cnt .modal-comment').map {|el| [el.find('.comment-username').text, el.find('.comment-body').text]}
      }
      # create records
      post = create(:post)
      user = post.user
      comment = create(:comment, user: user, post: post)
      comment2 = create(:comment, user: user, post: post)
      # sign in, visit root
      login_and_visit_root(user)

      # comment
      within_first_post do
        # assert comments - comments section
        assert_css('.view-all-comments', text: I18n.t('views.post_card.view_all_comments', count: 2))
        assert_css('.top-comment', text: "#{user.username} #{comment.body}")
        assert_css('.top-comment', text: "#{user.username} #{comment2.body}")
        # assert comments - modal
        find('.show-comments-btn').click
        assert_css '.modal-comment-cnt', visible: true
        expect(mapped_comments.call).to eq([
          [user.username, comment.body], 
          [user.username, comment2.body]
        ])

        ## delete first comment
        within(first('.modal-comment-cnt')) { find('.btn-delete-comment').click }
        wait_for_turbo
        
        # assert comments - comments section
        assert_css('.view-all-comments', text: I18n.t('views.post_card.view_all_comments', count: 1), visible: false)
        assert_css('.top-comment', text: "#{user.username} #{comment2.body}", visible: false)
        # assert comments - modal
        expect(mapped_comments.call).to eq([ 
          [user.username, comment2.body]
        ])

        ## delete last comment
        within(first('.modal-comment-cnt')) { find('.btn-delete-comment').click }
        wait_for_turbo

        # assert comments - comments section
        assert_no_css '.view-all-comments'
        assert_no_css '.top-comment'
        # assert comments - modal
        within('.comments-modal') { assert_css('.no-comments-msg') }
      end
    end

    it 'cannot add comment / see comments info if post not allow it' do
      user = create(:user, private: false)
      @user.follow!(user)
      create(:post, user: user, allow_comments: false)
      # sign in, visit root
      login_and_visit_root(@user)
      within_first_post do
        assert_no_css('.comments-cnt')
        assert_no_css('.show-comments-btn')
        assert_no_css('.comments-modal', visible: :all)
        assert_no_css('.add-comment-form')
      end
    end

    it 'cannot see likes count and likers list if post does not allow it' do
      user = create(:user, private: false)
      @user.follow!(user)
      create(:post, user: user, show_likes_count: false)
      # sign in, visit root
      login_and_visit_root(@user)
      within_first_post do
        assert_no_css('.post-likes')
        assert_no_css('.likers-modal', visible: :all)
      end
    end

    it 'can see likes count and likers list for own post even if post does not allow it' do
      create(:post, user: @user, show_likes_count: false)
      # sign in, visit root
      login_and_visit_root(@user)
      within_first_post do
        assert_css('.post-likes')
        assert_css('.likers-modal', visible: :all)
      end
    end

    it "tries to delete someone's else comment" do
      # create records
      post = create(:post)
      user = post.user
      user2 = create(:user)
      comment = create(:comment, user: user2, post: post)
      comment2 = create(:comment, user: user, post: post)

      # sign in, visit root
      login_and_visit_root(user)
      within_first_post do
        find('.show-comments-btn').click
        within first('.modal-comment-cnt .modal-comment') do
          assert_no_css '.btn-delete-comment'
        end
      end
    end

    context 'using maps' do
      it "can go to 'set postion' map, set nothing and confirm" do
        do_location_test
      end

      it "can go to 'set postion' map, set nothing and go back" do
        do_location_test(confirm: false)
      end

      it "can go to 'set postion' map, set location and confirm" do
        do_location_test(location: 'Warsaw', exp_longitude: 21.071432, exp_latitude: 52.233717, exp_location_provided: true)
      end

      it "can go to 'set postion' map, set location and go back" do
        do_location_test(confirm: false, location: 'Warsaw')
      end

      it 'cannot see location if not provided' do
        post = create(:post, user: @user)
        # sign in, visit root
        login_and_visit_root(@user)
        within_first_post do
          # no location set info
          expect(find('.location').text).to eq I18n.t('views.post_modal.no_location_set')
          # can't be clicked
          find('.location').click
        end
        # no map - location can't be clicked
        expect(page).to_not have_selector '#mapModal.show'
      end

      it 'cannot see location if provided' do
        longitude = 21.071432
        latitude = 52.233717
        post = create(:post, user: @user, longitude: longitude, latitude: latitude)
        # sign in, visit root
        login_and_visit_root(@user)
        within_first_post do
          expect(page).to have_selector '.location-loaded'
          # location info
          expect(find('.location').text).to eq 'Warsaw, Poland'
          # can be clicked
          find('.location').click
        end
        # map shows - location can be clicked
        expect(page).to have_selector '#mapModal.show'
        within '#mapModal' do
          # assert marker set properly
          expect(find('.leaflet-popup-content').text).to eq 'Warsaw, Poland'
          data = evaluate_script('Object.entries(window.map_markers._layers)[0][1]._latlng')
          expect(data['lat']).to eq latitude
          expect(data['lng']).to eq longitude
        end
      end
    end

    context 'stories' do
      it 'sees info about no stories' do
        user = create(:user, private: false)
        post = create(:post, user: user)
        @user.follow!(user)
        login_and_visit_root(@user)
        # no stories added, just post
        within('.stories-card') { assert_content I18n.t('views.posts.no_stories') }
        create(:story, user: user)
        visit current_path
        # story added, no info
        within('.stories-card') { assert_no_content I18n.t('views.posts.no_stories') }
      end

      it 'sees stories' do
        # create user and post - no stories to be seen
        user = create(:user, private: false)
        create(:post, user: user)
        # create user(not followed) and story - no stories to be seen
        user2 = create(:user, private: false)
        create(:story, user: user2)
        # create user(followed) and 2 stories - 2 stories to be seen
        user3 = create(:user, private: false)
        2.times { create(:story, user: user3) }
        @user.follow!(user3)

        # see page and assert 2 stories visible
        login_and_visit_root(@user)
        within '.stories-card' do
          expect(all('.story').count).to eq 2
          expect(all('.story .username').map(&:text).uniq).to eq [user3.username]
        end
      end
    end
  end
end