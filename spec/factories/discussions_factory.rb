FactoryBot.define do
  factory :discussion do
    user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }

    trait :approved do
      status { 'approved' }
    end

    trait :rejected do
      status { 'rejected' }
    end
  end
end
