# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { Devise.friendly_token }

    factory :advisor, class: 'Advisor' do
      type "Advisor"
      first_name Faker::Name.first_name
      last_name Faker::Name.last_name
    end

    factory :delegate, class: 'Delegate' do
      type "Delegate"
    end

    trait :confirmed do
      after(:build) { |user| user.skip_confirmation! }
    end
  end
end
