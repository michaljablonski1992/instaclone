FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@test.com" }
    sequence(:full_name) { |n| "Test subject#{n}" }
    sequence(:username) { |n| "test_username#{n}" }
    password { 'fancy_password123' }
    password_confirmation { 'fancy_password123' }
  end
end
