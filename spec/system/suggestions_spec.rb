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
    if count > 0
      expect(all('.suggestions-list .suggestion').count).to eq count
    else
      expect(page).to have_selector '.no-suggestions-info'
    end
  end

  def prepare_suggestions_page(count, _private: false, homepage: false)
    create_suggestions_mesh(count, _private: _private)
    # login user and visit another's user profile page
    login_and_visit_root(@user2)
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

    it 'sees no suggestions info' do
      User.destroy_all
      user = create(:user)

      # homepage
      login_and_visit_root(user)
      assert_suggestions_count(0)

      # see more
      visit suggestions_path
      assert_suggestions_count(0)
    end
    
    it "sees no 'see more' link when there is nothing more to show" do
      prepare_suggestions_page(User::HOME_PAGE_SUGGESTIONS_COUNT, homepage: true)
      expect(page).to_not have_selector '#see-more-suggestions'
    end

    it "sees 'see more' link when there is more to show" do
      prepare_suggestions_page(User::HOME_PAGE_SUGGESTIONS_COUNT + 1, homepage: true)
      expect(page).to have_selector '#see-more-suggestions'
    end
  end

  
  private
  
end