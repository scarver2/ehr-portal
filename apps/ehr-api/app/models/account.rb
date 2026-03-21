# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user, inverse_of: :account

  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validates :status, presence: true, inclusion: { in: %w[unverified verified closed] }

  # Password validation using bcrypt
  def valid_password?(password)
    BCrypt::Password.new(password_hash) == password
  rescue BCrypt::Errors::InvalidHash
    false
  end
end
