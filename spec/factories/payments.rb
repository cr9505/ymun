FactoryGirl.define do
  factory :payment do
    state 'approved'
    trait :not_approved do
      state 'created'
    end
  end
end