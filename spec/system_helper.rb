require 'rails_helper'
require 'capybara/rails'
require 'devise'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  ## devise
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.use_transactional_fixtures = true
end

def login_and_visit_root(user)
  login_and_redirect(user, root_path)
end

def login_and_redirect(user, path)
  login_as user
  visit path
end

def sign_out
  find('.profile-dropdown').click
  find('.profile-menu .logout').click
end

def sign_in(email, password)
  find('#user_login').set ''
  find('#user_password').set ''
  find('#user_login').set email
  find('#user_password').set password
  click_on 'Log in'
end

def assert_content(content)
  expect(page).to have_content(content)
end
def assert_no_content(content)
  expect(page).to_not have_content(content)
end

def assert_css(selector, **args)
  expect(page).to have_css(selector, **args)
end
def assert_no_css(selector, **args)
  expect(page).to have_no_css(selector, **args)
end

def assert_current_path(path)
  expect(page).to have_current_path(path)
end

def assert_flash(msg)
  expect(all('#flash_message .flash').any? {|el| el.text == msg  }).to be true
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

# hides bootstrap modal
def hide_bs_modal(selector)
  page.evaluate_script("bootstrap.Modal.getInstance(document.querySelector('#{selector}')).hide();")
end

def remove_flashes
  all('#flash_message .flash').each {|el| el.click }
end