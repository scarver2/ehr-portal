# app/services/fake_payer_gateway.rb
# frozen_string_literal: true

class FakePayerGateway
  def initialize(verification)
    @verification = verification
  end

  def check_eligibility
    sleep(@verification.insurance_profile.payer&.simulated_latency || 1.5)

    {
      reference_id:      SecureRandom.hex(8),
      payer_name:        @verification.insurance_profile.payer_name || "Aetna Demo",
      plan_name:         ["Silver PPO", "Gold HMO", "Premier EPO"].sample,
      copay_cents:       [2500, 3500, 5000].sample,
      deductible_cents:  [100_000, 150_000, 300_000].sample,
      oop_max_cents:     [500_000, 650_000, 800_000].sample,
      eligibility:       "active",
      benefits: {
        primary_care: true,
        specialist:   true,
        telehealth:   [true, false].sample
      }
    }
  end
end
