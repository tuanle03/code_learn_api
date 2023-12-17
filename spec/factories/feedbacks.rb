FactoryBot.define do
  factory :feedback do
    user_id { 1 }
    post_id { 1 }
    content { Faker::Lorem.sentence }
  end
end
