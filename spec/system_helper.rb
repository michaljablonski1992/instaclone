require 'rails_helper'
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

def wait_for_turbo(timeout = nil)
  if has_css?('.turbo-progress-bar', visible: true, wait: (0.25).seconds)
    has_no_css?('.turbo-progress-bar', wait: timeout.presence || 5.seconds)
  end
end

def wait_for_turbo_frame(selector = 'turbo-frame', timeout = nil)
  if has_selector?("#{selector}[busy]", visible: true, wait: (0.25).seconds)
    has_no_selector?("#{selector}[busy]", wait: timeout.presence || 5.seconds)
  end
end