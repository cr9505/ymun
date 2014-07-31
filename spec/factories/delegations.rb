# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delegation do
    ignore do
      advisor_count 1
    end
    sequence(:name) { |n| "Delegation #{n}" }
    step 1

    association :address, factory: :address

    after(:build) do |delegation, evaluator|
      evaluator.advisor_count.times do
        delegation.advisors << build(:advisor, :delegation => delegation)
      end
    end
    after(:create) do |delegation|
      delegation.advisors.each { |bar| bar.save! }
    end

    trait(:skip_late_registration_checks) do
      after(:build) do |delegation|
        delegation.class.skip_callback(:save, :before, :check_for_late_registration)
        delegation.class.skip_callback(:save, :before, :check_for_late_delegates)
        Advisor.skip_callback(:save, :after, :check_for_late_advisor)
      end
    end
  end
end
