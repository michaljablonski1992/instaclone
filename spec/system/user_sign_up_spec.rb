require 'system_helper'

RSpec.describe 'Sign in page', type: :system do
  
  it 'shows error on invalid data' do
    # visit sign up and assert no errors
    visit new_user_registration_path
    assert_no_content "Email can't be blank"
    assert_no_content "Password can't be blank"
    assert_no_content "Full name can't be blank"
    assert_no_content "Username can't be blank"

    # try to sign up, assert errors
    click_on 'Sign up'
    assert_content "Email can't be blank"
    assert_content "Password can't be blank"
    assert_content "Full name can't be blank"
    assert_content "Username can't be blank"
  end

  it 'shows error on existing email' do
    # create existing user
    @user = create(:user)

    # visit sign up and assert no errors
    visit new_user_registration_path
    assert_no_content 'Email has already been taken'

    # try to sign up, assert errors
    find('#user_email').set @user.email
    click_on 'Sign up'
    assert_content 'Email has already been taken'
  end

  it 'allows to make new account and then sign user in' do
    # visit sign up
    visit new_user_registration_path

    # fill form
    email = 'new_user@test.com'
    password = 'newuserpassword1!'
    find('#user_email').set email
    find('#user_full_name').set 'New User'
    find('#user_username').set 'UsernameNew123'
    find('#user_password').set password
    find('#user_password_confirmation').set password

    # sign up, assert welcome message and signed in
    click_on 'Sign up'
    assert_content 'Welcome! You have signed up successfully.'
    assert_current_path(root_path)
  end

end