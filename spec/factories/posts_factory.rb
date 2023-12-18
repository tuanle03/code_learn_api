FactoryBot.define do
  factory :post do
    user
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    total_view { Faker::Number.number(digits: 3) }

    trait :approved do
      status { 'approved' }
    end

    trait :pending do
      status { 'pending' }
    end
  end
end
