# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mun_country, class: MUNCountry do
    name { Faker::Address.country }
  end
end
