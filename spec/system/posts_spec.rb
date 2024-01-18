require 'system_helper'

RSpec.describe 'Posts', type: :system do
  before(:each) { @user = create(:user) }

  it 'shows errors on invalid post' do
    # sign in, visit root
    login_as(@user)
    visit root_path
    # click create post -> modal
    find('#create-post').click
    expect(page).to have_selector '#postModal'

    # click post, assert errors
    within('#postModal') { click_on 'Post' }
    assert_flash "Images can't be blank"
    assert_flash "Caption can't be blank"
  end

  it 'shows error on image invalid file type' do
    # sign in, visit root
    login_as(@user)
    visit root_path
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
    login_as(@user)
    visit root_path

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

  it 'gives ability to like/unlike post' do
    post = create(:post)
    user = post.user
    # sign in, visit root
    login_as(user)
    visit root_path

    # expect no likes yet - db
    expect(post.likes.count).to eq 0
    expect(post.likers.count).to eq 0

    ## like the post
    # assert within post
    within '#posts-list' do
      within first('.post-cnt') do
        # no likes yet
        expect(find('.post-likes').text).to eq I18n.t('views.post_card.likes', count: 0)

        # like the post
        find('.like-btn').click
        wait_for_turbo

        # expect the post is liked
        expect(find('.post-likes').text).to eq I18n.t('views.post_card.likes', count: 1)
      end
    end

    # expect post is liked by 'liker'
    expect(post.likes.count).to eq 1
    expect(post.likers.count).to eq 1
    expect(post.likers.first).to eq user
  end

  it 'gives ability to unlike post' do
    post = create(:post)
    user = post.user
    like = create(:like, post: post, user: user)
    # sign in, visit root
    login_as(user)
    visit root_path

    # expect post is liked by 'liker'
    expect(post.likes.count).to eq 1
    expect(post.likers.count).to eq 1
    expect(post.likers.first).to eq user

    ## unlike the post
    within '#posts-list' do
      within first('.post-cnt') do
        # unlike the post
        find('.like-btn').click
        wait_for_turbo

        # expect the post is unliked
        expect(find('.post-likes').text).to eq I18n.t('views.post_card.likes', count: 0)
      end
    end

    # expect post is unliked by 'liker'
    expect(post.likes.count).to eq 0
    expect(post.likers.count).to eq 0
  end

  it 'gives ability to add comment' do
    comment_body = 'Example comment test'
    post = create(:post)
    user = post.user
    # sign in, visit root
    login_as(user)
    visit root_path

    # assert no comments yet
    expect(post.comments.count).to eq 0

    # comment
    within '#posts-list' do
      within first('.post-cnt') do
        # assert no comments
        assert_no_css('.view-all-comments')
        assert_no_css('.top-comment')
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
  end

  it 'gives ability to delete my own comments' do
    mapped_comments = -> {
      all('.modal-comment-cnt .modal-comment').map {|el| [el.find('.comment-username').text, el.find('.comment-body').text]}
    }
    post = create(:post)
    user = post.user
    comment = create(:comment, user: user, post: post)
    comment2 = create(:comment, user: user, post: post)
    # sign in, visit root
    login_as(user)
    visit root_path

    # comment
    within '#posts-list' do
      within first('.post-cnt') do
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
        assert_no_css('.view-all-comments')
        assert_no_css('.top-comment')
        # assert comments - modal
        within('.comments-modal') { assert_css('.no-comments-msg') }
      end
    end
  end
end