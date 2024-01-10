require 'system_helper'

RSpec.describe 'Sign in page', type: :system do
  before(:each) { @user = create(:user) }

  it 'shows error on invalid credentials' do
    # visit sign in and assert no errors
    visit new_user_session_path
    assert_no_content 'Invalid Email or password.'

    # try to sign in, assert error 
    sign_in('non_existing@email.com', 'wrongpassword')
    assert_content 'Invalid Email or password.'
  end

  it 'shows error on invalid password' do
    # visit sign in and assert no errors
    visit new_user_session_path
    assert_no_content 'Invalid Email or password.'

    # try to sign in, assert error 
    sign_in(@user.email, 'wrongpassword')
    assert_content 'Invalid Email or password.'
  end

  it 'log me in on valid credentials' do
    # visit sign in and assert no errors
    visit new_user_session_path
    assert_no_content 'Invalid Email or password.'

    # sign in, assert signed in
    sign_in(@user.email, @user.password)
    assert_content 'Signed in successfully.'
  end
end