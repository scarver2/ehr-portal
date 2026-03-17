# spec/factories/admin_users.rb

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password              { 'Password1!' }
    password_confirmation { 'Password1!' }
  end
end
