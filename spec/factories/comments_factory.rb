FactoryBot.define do
  factory :comment do
    user
    linked_object_id { 1 }
    linked_object_type { 'Discussion' }
    content { Faker::Lorem.paragraph }

    trait :approved do
      status { 'approved' }
    end
  end
end
