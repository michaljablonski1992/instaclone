require 'system_helper'
require './spec/helpers/system_posts_helper'

RSpec.describe 'Posts', type: :system do
  include SystemPostsHelper
  before(:each) { @user = create(:user) }

  describe 'user' do
    it 'submits invalid post' do
      # sign in, visit root
      login_and_visit_root(@user)
      # click create post -> modal
      find('#create-post').click
      expect(page).to have_selector '#postModal'

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
      expect(page).to have_selector '#postModal'

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
      expect(page).to have_selector '#postModal'

      # fill
      within('#postModal') do
        # add non valid file - only images allowed
        page.attach_file(Rails.root.join('spec/fixtures/image.png')) do
          find('.filepond--drop-label').click
        end
        find('#post_caption').set 'Example caption'

        click_on 'Post'
      end

      # assert post has been made
      expect(page).to_not have_selector '#postModal'
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
  end
end