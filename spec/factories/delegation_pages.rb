FactoryGirl.define do
  factory :delegation_page do
    sequence(:name) { |n| "Delegation Page #{n}" }
    sequence(:step)
  end
end