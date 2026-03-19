# frozen_string_literal: true

FactoryBot.define do
  factory :encounter do
    association :patient,  factory: :user, role: :patient
    association :provider, factory: :provider

    encounter_type { :office_visit }
    status         { :scheduled }
    encountered_at { 1.day.ago }
    chief_complaint { Faker::Lorem.sentence(word_count: 4) }
    notes          { nil }

    trait :telehealth do
      encounter_type { :telehealth }
    end

    trait :emergency do
      encounter_type { :emergency }
    end

    trait :follow_up do
      encounter_type { :follow_up }
    end

    trait :annual_exam do
      encounter_type { :annual_exam }
    end

    trait :scheduled do
      status { :scheduled }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
