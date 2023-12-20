FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    avatar_url { Faker::Avatar.image }
    email { Faker::Internet.email }
    password { 'password123' }
    role { 'user' }

    trait :admin do
      role { 'admin' }
    end

  end
end
