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
end