# apps/ehr-api/app/models/user.rb
# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    admin: "admin",
    provider: "provider",
    staff: "staff",
    patient: "patient"
  }, validate: true

  validates :role, presence: true
end
