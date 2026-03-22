# spec/factories/users.rb

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }

    # Skip validation during creation since roles are assigned in after(:create) hook
    to_create { |instance| instance.save!(validate: false) }

    # Default role: patient
    after(:create) do |user|
      # Create Rodauth Account with password
      Account.create!(
        user_id: user.id,
        email: user.email,
        password_hash: BCrypt::Password.create('Password1!'),
        status: 'verified'
      )

      # Assign default patient role via Rolify
      user.add_role(:patient) unless user.roles.any?
    end

    # Role assignment traits
    trait :provider do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:provider)
      end
    end

    trait :staff do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:staff)
      end
    end

    trait :patient do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:patient)
      end
    end

    # Note: :admin trait removed — admin users are now AdminUser model only
  end
end
