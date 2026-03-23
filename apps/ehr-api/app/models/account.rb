# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user, inverse_of: :account

  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validates :status, presence: true, inclusion: { in: %w[unverified verified closed] }

  # JWT Configuration
  JWT_ALGORITHM = 'HS256'
  JWT_TTL = 1.day
  JWT_ISSUER = 'ehr-portal-api'

  # Password validation using bcrypt
  def valid_password?(password)
    BCrypt::Password.new(password_hash) == password
  rescue BCrypt::Errors::InvalidHash
    false
  end

  # Generate JWT token using Rodauth's standard claims
  def generate_jwt_token
    payload = {
      sub: user_id.to_s,                    # Subject: user ID
      email: email,                         # User email
      iat: Time.current.to_i,              # Issued at
      exp: (Time.current + JWT_TTL).to_i,  # Expiration (1 day)
      iss: JWT_ISSUER                      # Issuer
    }

    secret = Rails.application.secret_key_base
    JWT.encode(payload, secret, JWT_ALGORITHM)
  end

  # Verify JWT token and return decoded payload, or nil if invalid
  def self.verify_jwt_token(token)
    return nil if token.blank?

    begin
      secret = Rails.application.secret_key_base
      JWT.decode(token, secret, true, { algorithm: JWT_ALGORITHM }).first
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end

  # Find user from JWT token
  def self.find_user_from_jwt(token)
    payload = verify_jwt_token(token)
    return nil unless payload

    user_id = payload['sub']&.to_i
    return nil unless user_id

    user = User.find_by(id: user_id)
    # Only return user if account is verified
    user if user && user.account&.status == 'verified'
  end
end
