require 'system_helper'

RSpec.describe 'Suggestions feature', type: :system do
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
      ### TODO - no suggestions page yet
    end

    it 'can use follow feature from suggestions page' do
      ### TODO - no suggestions page yet
    end

    it 'can use follow features' do
      ### TODO FIXME - follow/cancel will show another suggestions
      ## suggestions should stay the same 
      ## if cancel(request sent) then just button change
      ## if followed(not private user) then add additional suggestion at the bottom
      # binding.pry
    end
    
  end

  
  private
  
end