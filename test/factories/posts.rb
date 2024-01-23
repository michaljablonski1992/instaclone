FactoryBot.define do
  factory :post do
    user
    caption { "Test text" }
    longitude { 1.5 }
    latitude { 1.5 }
    allow_comments { true }
    show_likes_count { true }
    images { [Rack::Test::UploadedFile.new('spec/fixtures/view.jpg', 'image/jpg')] }
  end
end
