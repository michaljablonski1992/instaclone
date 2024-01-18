FactoryBot.define do
  factory :comment do
    user
    post
    sequence(:body) {|n| "Test comment #{n}" }
  end
end
