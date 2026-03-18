# spec/factories/users.rb

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password              { 'Password1!' }
    password_confirmation { 'Password1!' }
    role                  { :patient }

    trait :admin do
      role { :admin }
    end
    trait :provider do
      role { :provider }
    end
    trait :staff do
      role { :staff }
    end
    trait :patient do
      role { :patient }
    end
  end
end
