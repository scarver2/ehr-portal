# spec/factories/specialties.rb
# frozen_string_literal: true

FactoryBot.define do
  factory :specialty do
    sequence(:name) { |n| "Specialty #{n}" }
    category { ['Medical', 'Surgical', 'Primary Care'].sample }
  end
end
