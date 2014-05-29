factory :user do
  sequence :email { |n| "user#{n}@example.com" }
  password { Devise.friendly_token }

  factory :advisor do
    type "Advisor"
  end

  factory :delegate do
    type "Delegate"
  end
end