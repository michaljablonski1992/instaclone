require 'system_helper'
require './spec/helpers/system_follows_helper'

RSpec.describe 'Suggestions feature', type: :system do
  include SystemFollowsHelper
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  ## to see suggestions user's following have to have followings and follows
  def create_suggestions_mesh(users_count, _private: false)
    users_count.times do
      u = create(:user, private: _private)
      u.follow!(@user)
    end
    @user2.follow!(@user)
  end

  def assert_suggestions_count(count)
    expect(all('.suggestions-list .suggestion').count).to eq count
  end

  def prepare_suggestions_page(count, _private: false, homepage: false)
    create_suggestions_mesh(count, _private: _private)
    # login user and visit another's user profile page
    login_as @user2
    visit root_path
    unless homepage
      find('#see-more-suggestions').click
      wait_for_turbo
    end
  end

  describe 'user' do
    it 'can see User::HOME_PAGE_SUGGESTIONS_COUNT suggestions at home page' do
      prepare_suggestions_page(User::HOME_PAGE_SUGGESTIONS_COUNT + 10, homepage: true)

      # can see suggestions
      assert_suggestions_count(User::HOME_PAGE_SUGGESTIONS_COUNT)
    end

    it 'can see more suggestions(up to User::SUGGESTIONS_COUNT) at suggestions page' do
      prepare_suggestions_page(User::SUGGESTIONS_COUNT + 10)

      # can see suggestions
      assert_suggestions_count(User::SUGGESTIONS_COUNT)
    end

    it 'can use follow features from suggestions page - private user' do
      prepare_suggestions_page(User::SUGGESTIONS_COUNT + 10, _private: true)

      # can user follow feature
      test_follow_private("##{first('.suggestions-list .suggestion')['id']}")
    end

    it 'can use follow features from suggestions page - non private user' do
      prepare_suggestions_page(User::SUGGESTIONS_COUNT + 10)

      # can user follow feature
      test_follow("##{first('.suggestions-list .suggestion')['id']}")
    end

    it 'can use follow features - private user' do
      prepare_suggestions_page(2, _private: true, homepage: true)

      test_follow_private("##{first('.suggestions-list .suggestion')['id']}")
    end

    it 'can use follow features - non-private user' do
      prepare_suggestions_page(2, _private: false, homepage: true)

      test_follow("##{first('.suggestions-list .suggestion')['id']}")
    end
    
  end

  
  private
  
end