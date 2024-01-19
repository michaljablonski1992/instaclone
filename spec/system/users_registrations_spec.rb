require 'system_helper'

RSpec.describe 'Users registrations', type: :system do
  
  describe 'user' do
    context 'tries to sign up' do
      it 'submits blank data' do
        # visit sign up and assert no errors
        visit new_user_registration_path

        # try to sign up, assert errors
        click_on 'Sign up'
        within('.inner-flash') do 
          assert_content "Email can't be blank"
          assert_content "Password can't be blank"
          assert_content "Full name can't be blank"
          assert_content "Username can't be blank"
        end
      end

      it 'submits invalid data' do
        # visit sign up and assert no errors
        visit new_user_registration_path
        find('#user_email').set 'not_email_at_all'
        find('#user_username').set 'invalid username !'

        # try to sign up, assert errors
        click_on 'Sign up'
        within('.inner-flash') do 
          assert_content 'Email is invalid'
          assert_content 'Username is invalid'
        end
      end

      it 'submits existing email' do
        # create existing user
        @user = create(:user)

        # visit sign up and assert no errors
        visit new_user_registration_path

        # try to sign up, assert errors
        find('#user_email').set @user.email
        click_on 'Sign up'
        within('.inner-flash') { assert_content 'Email has already been taken' }
      end

      it 'submits existing username' do
        # create existing user
        @user = create(:user)

        # visit sign up and assert no errors
        visit new_user_registration_path

        # try to sign up, assert errors
        find('#user_username').set @user.username
        click_on 'Sign up'
        within('.inner-flash') { assert_content 'Username has already been taken' }
      end

      it 'submits valid data and then signed in' do
        # visit sign up
        visit new_user_registration_path

        # fill form
        find('#user_email').set 'new_user@test.com'
        find('#user_full_name').set 'New User'
        find('#user_username').set 'UsernameNew123'
        find('#user_password').set 'newuserpassword1!'
        find('#user_password_confirmation').set 'newuserpassword1!'

        # sign up, assert welcome message and signed in
        click_on 'Sign up'
        assert_content I18n.t('devise.registrations.signed_up')
        assert_current_path(root_path)
      end
    end

    context 'tries to edit registrations data' do
      it 'submits no current password' do
        # create user and login
        user = create(:user)
        login_and_redirect(user, edit_user_registration_path)

        # submit and assert no current password provided
        click_button 'Submit'
        within('.inner-flash') { assert_content "Current password can't be blank" }
      end

      it 'submits no data at all' do
        # create user and login
        user = create(:user)
        login_and_redirect(user, edit_user_registration_path)
        
        # fill all with empty data, provide current password
        find('#user_full_name').set ''
        find('#user_username').set ''
        find('#user_bio').set ''
        find('#user_email').set ''
        find('#user_phone_number').set ''
        find('#user_current_password').set user.password

        # submit and assert errors
        click_button 'Submit'
        within('.inner-flash') do 
          assert_content "Email can't be blank"
          assert_content "Full name can't be blank"
          assert_content "Username can't be blank"
        end
      end

      it 'submits taken email' do
        # create users and login
        user = create(:user)
        user2 = create(:user)
        login_and_redirect(user, edit_user_registration_path)
        
        # set taken email, provide current password
        find('#user_email').set user2.email
        find('#user_current_password').set user.password

        # submit and assert errors
        click_button 'Submit'
        within('.inner-flash') { assert_content 'Email has already been taken' }
      end

      it 'submits invalid data' do
        # create users and login
        user = create(:user)
        login_and_redirect(user, edit_user_registration_path)
        
        # set invalid data, provide current password
        find('#user_email').set 'not_email at all'
        find('#user_username').set 'invalid! username'
        find('#user_current_password').set user.password

        # submit and assert errors
        click_button 'Submit'
        within('.inner-flash') do 
          assert_content 'Email is invalid'
          assert_content 'Username is invalid'
        end
      end

      it 'submits correct data' do
        # hash of changes
        data_changes = {
          full_name: 'new full name',
          username: 'username',
          bio: 'bio',
          email: 'new_email@test.com',
          phone_number: 'phone_number',
        }

        # create user and login
        user = create(:user)
        login_and_redirect(user, edit_user_registration_path)
        
        # fill form with changes, provide current password
        data_changes.each { |attr, val| find("#user_#{attr}").set val }
        find('#user_current_password').set user.password

        # submit and assert update made, redirected to root path
        click_button 'Submit'
        within('#flash_message') { assert_content I18n.t('devise.registrations.updated') }
        assert_current_path root_path
      end

      it 'submits password change' do
        new_password = 'newpassword123'
        # create user and login
        user = create(:user)
        login_and_redirect(user, edit_user_registration_path)
        
        # fill form with changes, provide current password
        find('#user_password').set new_password
        find('#user_password_confirmation').set new_password
        find('#user_current_password').set user.password

        # submit and assert update made, redirected to root path
        click_button 'Submit'
        within('#flash_message') { assert_content I18n.t('devise.registrations.updated') }
        assert_current_path root_path

        # sign out, then sign in using new password
        remove_flashes
        sign_out
        sign_in(user.email, new_password)
        assert_content I18n.t('devise.sessions.signed_in')
        assert_current_path root_path
      end
    end
  end

end