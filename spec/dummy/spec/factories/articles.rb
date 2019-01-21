FactoryBot.define do
  factory :article do
    title { "Title" }
    published_at { 1.day.ago }
  end
end
