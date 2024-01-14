require 'capybara/rails'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  ## devise
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.use_transactional_fixtures = true
end

def sign_in(email, password)
  find('#user_email').set email
  find('#user_password').set password
  click_on 'Log in'
end

def assert_content(content)
  expect(page).to have_content(content)
end

def assert_no_content(content)
  expect(page).to_not have_content(content)
end

def assert_current_path(path)
  expect(page).to have_current_path(path)
end

def assert_flash(msg)
  all('#flash_message .flash').any? {|el| el.text == msg  }
end