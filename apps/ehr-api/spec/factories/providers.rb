# spec/factories/providers.rb
# frozen_string_literal: true

FactoryBot.define do
  factory :provider do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    npi         { Faker::Number.number(digits: 10).to_s }
    specialty
    clinic_name { 'General Hospital' }
  end
end
