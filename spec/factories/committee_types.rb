# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :committee_type do
    name { Faker::Commerce.department }
  end
end
