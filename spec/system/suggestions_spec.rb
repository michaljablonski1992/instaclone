require 'system_helper'

RSpec.describe 'Suggestions feature', type: :system do
  include DomIdsHelper
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  describe 'user' do
    it 'can see User::HOME_PAGE_SUGGESTIONS_COUNT suggestions at home page' do
      10.times { create(:user) }
      # login user and visit another's user profile page
      login_as @user2
      visit root_path

      # can see suggestions
      expect(all('.suggestions-list .suggestion').count).to eq User::HOME_PAGE_SUGGESTIONS_COUNT
    end

    it 'can see more suggestions at suggestions page' do
      ### TODO - test me
    end

    it 'can use follow feature from suggestions page' do
      ### TODO - test me
    end

    it 'can use follow features - private user' do
      user3 = create(:user)
      user4 = create(:user)
      # login user and visit another's user profile page
      login_as @user2
      visit root_path

      within "##{suggestion_id(user3)}" do
        assert_no_css('.cancel-request-btn')
        find('.follow-btn').click
        assert_no_css('.follow-btn')
        assert_css('.cancel-request-btn')
      end
    end

    it 'can use follow features - non-private user' do
      user3 = create(:user, private: false)
      user4 = create(:user, private: false)
      # login user and visit another's user profile page
      login_as @user2
      visit root_path

      within "##{suggestion_id(user3)}" do
        assert_no_css('.unfollow-btn')
        find('.follow-btn').click
        assert_no_css('.follow-btn')
        assert_css('.unfollow-btn')
      end
    end
    
  end

  
  private
  
end