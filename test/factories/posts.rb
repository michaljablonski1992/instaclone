FactoryBot.define do
  factory :post do
    user
    caption { "Test text" }
    allow_comments { true }
    show_likes_count { true }
    is_story { false }
    images { [Rack::Test::UploadedFile.new('spec/fixtures/view.jpg', 'image/jpg')] }
  end
end
