FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@test.com" }
    sequence(:full_name) { |n| "Test Subject#{n}" }
    sequence(:username) { |n| "test_username#{n}" }
    password { 'fancy_password123' }
    password_confirmation { 'fancy_password123' }
    bio { 'my bio is cool' }
    profile_pic { Rack::Test::UploadedFile.new('spec/fixtures/image.png', 'image/png') }
    private { true }
  end
end
