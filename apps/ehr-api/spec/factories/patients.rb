# spec/factories/patients.rb
# frozen_string_literal: true

FactoryBot.define do
  factory :patient do
    association :user, role: :patient

    first_name             { Faker::Name.first_name }
    last_name              { Faker::Name.last_name }
    date_of_birth          { Faker::Date.birthday(min_age: 1, max_age: 90) }
    gender                 { %w[male female other prefer_not_to_say].sample }
    mrn                    { Faker::Number.unique.number(digits: 8).to_s }
    phone                  { Faker::PhoneNumber.phone_number }
    address                { Faker::Address.full_address }
    emergency_contact_name  { Faker::Name.name }
    emergency_contact_phone { Faker::PhoneNumber.phone_number }

    trait :without_user do
      user { nil }
    end
  end
end
