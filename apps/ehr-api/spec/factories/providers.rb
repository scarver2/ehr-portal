# spec/factories/providers.rb

FactoryBot.define do
  factory :provider do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    npi         { Faker::Number.number(digits: 10).to_s }
    specialty   { 'Cardiology' }
    clinic_name { 'General Hospital' }
  end
end
