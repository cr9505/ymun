# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delegation do
    sequence(:name) { |n| "Delegation #{n}" }
    step 1
  end
end
