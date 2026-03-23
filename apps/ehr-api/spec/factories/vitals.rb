# frozen_string_literal: true

FactoryBot.define do
  factory :vital do
    encounter

    vital_type  { :heart_rate }
    value       { '72' }
    unit        { 'bpm' }
    observed_at { Time.current }
    notes       { nil }

    trait :blood_pressure do
      vital_type { :blood_pressure }
      value      { '120/80' }
      unit       { 'mmHg' }
    end

    trait :heart_rate do
      vital_type { :heart_rate }
      value      { '72' }
      unit       { 'bpm' }
    end

    trait :temperature do
      vital_type { :temperature }
      value      { '98.6' }
      unit       { '°F' }
    end

    trait :weight do
      vital_type { :weight }
      value      { '70' }
      unit       { 'kg' }
    end

    trait :height do
      vital_type { :height }
      value      { '175' }
      unit       { 'cm' }
    end

    trait :oxygen_saturation do
      vital_type { :oxygen_saturation }
      value      { '98' }
      unit       { '%' }
    end

    trait :respiratory_rate do
      vital_type { :respiratory_rate }
      value      { '16' }
      unit       { 'breaths/min' }
    end

    trait :bmi do
      vital_type { :bmi }
      value      { '22.9' }
      unit       { 'kg/m²' }
    end
  end
end
