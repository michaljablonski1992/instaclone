FactoryBot.define do
  factory :story, parent: :post do
    is_story { true }
  end
end
