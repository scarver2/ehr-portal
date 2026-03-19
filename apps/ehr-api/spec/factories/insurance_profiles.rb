# spec/factories/insurance_profiles.rb
# frozen_string_literal: true

FactoryBot.define do
  factory :insurance_profile do
    association :user
    association :payer

    sequence(:member_id) { |n| "MBR#{n.to_s.rjust(7, '0')}" }
    payer_name { "Aetna" }
    status     { "pending" }
    raw_response { {} }
  end
end
