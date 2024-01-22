require 'system_helper'

RSpec.describe 'Suggestions feature', type: :system do
  before(:each) { @user = create(:user, private: false); @user2 = create(:user) }

  it 'can discovery new users by posts' do
    priv_users = []
    5.times { u = create(:user); create(:post, user: u); priv_users << u }
    users = []
    3.times { u = create(:user, private: false); create(:post, user: u); users << u }
    login_as @user
    visit root_path
    find('#discover-link').click

    # only non private can be seen in discovery
    expect(all('.profile-post').count).to eq 3

    # only non private and not followed can be seen in discovery
    @user.follow!(users.last)
    visit current_path
    expect(all('.profile-post').count).to eq 2
  end
end