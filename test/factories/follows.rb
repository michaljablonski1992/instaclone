FactoryBot.define do
  factory :follow do
    association :follower, factory: :user
    association :followed, factory: :user
    accepted { true }
  end
end
