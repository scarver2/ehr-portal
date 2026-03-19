# spec/factories/payers.rb
# frozen_string_literal: true

FactoryBot.define do
  factory :payer do
    sequence(:name)       { |n| "Payer #{n}" }
    sequence(:payer_code) { |n| "PAYER#{n.to_s.rjust(3, '0')}" }
    clearinghouse         { "Availity" }
    api_endpoint          { "https://api.availity.com/eligibility" }
    requires_auth         { true }
    active                { true }
    response_time_ms      { 1200 }
    metadata              { {} }

    trait :inactive do
      active { false }
    end
  end
end
