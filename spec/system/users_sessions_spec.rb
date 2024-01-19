require 'system_helper'

RSpec.describe 'Users sessions', type: :system do
  before(:each) { @user = create(:user) }

  describe 'user' do
    context 'tries to login' do
      it 'submits invalid credentials' do
        # visit sign in and assert no errors
        visit new_user_session_path

        # try to sign in, assert error 
        sign_in('non_existing@email.com', 'wrongpassword')
        assert_content 'Invalid Login or password.'
      end

      it 'submits invalid password' do
        # visit sign in and assert no errors
        visit new_user_session_path

        # try to sign in, assert error 
        sign_in(@user.email, 'wrongpassword')
        assert_content 'Invalid Login or password.'
      end

      it 'submits valid credentials - login using email' do
        # visit sign in and assert no errors
        visit new_user_session_path

        # sign in, assert signed in
        sign_in(@user.email, @user.password)
        assert_content I18n.t('devise.sessions.signed_in')
        assert_current_path root_path
      end

      it 'submits valid credentials - login using username' do
        # visit sign in and assert no errors
        visit new_user_session_path

        # sign in, assert signed in
        sign_in(@user.username, @user.password)
        assert_content I18n.t('devise.sessions.signed_in')
        assert_current_path root_path
      end
    end

    context 'tries to logout' do
      it 'uses logout button' do
        login_as(@user)
        visit root_path

        sign_out
        within('.flash') { assert_content I18n.t('devise.sessions.signed_out') }
        assert_current_path new_user_session_path
      end
    end
  end
end