FactoryGirl.define do
  factory :character do
    name { Faker::Name.name }
    seat_count 1
  end
end
