FactoryBot.define do
  factory :post do
    caption { "MyText" }
    longitude { 1.5 }
    latitude { 1.5 }
    user { nil }
    allow_comments { false }
    show_likes_count { false }
  end
end
