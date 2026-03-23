# frozen_string_literal: true

FactoryBot.define do
  factory :diagnosis do
    encounter

    icd10_code   { 'Z00.00' }
    description  { 'Encounter for general adult medical examination without abnormal findings' }
    status       { :active }
    diagnosed_at { Time.current }
    notes        { nil }

    trait :active do
      status { :active }
    end

    trait :resolved do
      status { :resolved }
    end

    trait :chronic do
      status { :chronic }
    end

    trait :ruled_out do
      status { :ruled_out }
    end

    trait :hypertension do
      icd10_code  { 'I10' }
      description { 'Essential (primary) hypertension' }
      status      { :chronic }
    end

    trait :type2_diabetes do
      icd10_code  { 'E11.9' }
      description { 'Type 2 diabetes mellitus without complications' }
      status      { :chronic }
    end

    trait :upper_respiratory do
      icd10_code  { 'J06.9' }
      description { 'Acute upper respiratory infection, unspecified' }
      status      { :active }
    end
  end
end
