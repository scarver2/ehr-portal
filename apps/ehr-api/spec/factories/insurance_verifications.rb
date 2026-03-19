# spec/factories/insurance_verifications.rb
# frozen_string_literal: true

FactoryBot.define do
  factory :insurance_verification do
    association :user
    association :insurance_profile

    payer_name { "Aetna" }
    status     { "pending" }
    raw_response { {} }

    trait :queued do
      status { "queued" }
    end

    trait :requesting do
      status { "requesting" }
    end

    trait :verified do
      status       { "verified" }
      payer_name   { "Aetna" }
      plan_name    { "Silver PPO" }
      copay_cents  { 2500 }
      deductible_cents { 100_000 }
      oop_max_cents    { 500_000 }
      verified_at  { Time.current }
      expires_at   { 24.hours.from_now }
    end

    trait :failed do
      status        { "failed" }
      error_message { "Simulated gateway error" }
    end
  end
end
