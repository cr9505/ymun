# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delegation_field do
    sequence(:slug) { |n| "delegation_field_#{n}" }
    class_name "String"
  end
end
