# frozen_string_literal: true

# Rodauth JWT Configuration
# Replaces Devise + devise-jwt hybrid with purpose-built JWT authentication
# Ref: https://rodauth.jeremyevans.net/

class Rodauth::Rails::Auth
  configure do
    # ============================================================================
    # Core Settings
    # ============================================================================
    enable :create_account, :verify_account, :verify_login_change, :reset_password,
           :jwt, :logout

    # Database table names
    accounts_table :accounts
    account_status_column :status
    account_password_hash_column :password_hash

    # JWT Configuration
    jwt_secret { Rails.application.credentials.secret_key_base }
    jwt_algorithm "HS256"
    jwt_issuer "ehr-portal-api"
    jwt_audience nil
    jwt_ttl 1.day.to_i

    # Use HMAC for JWT signing (HS256)
    jwt_algorithm "HS256"

    # ============================================================================
    # Password Configuration
    # ============================================================================
    # Use bcrypt for password hashing (same as Devise default)
    password_hash_algorithm :bcrypt

    # Bcrypt stretches (cost)
    if Rails.env.test?
      bcrypt_cost 1
    else
      bcrypt_cost 12
    end

    # ============================================================================
    # Account Status Management
    # ============================================================================
    # Require email verification after signup
    verify_account_set_password? false
    verify_account_autologin? true

    # Status values
    account_status_unverified "unverified"
    account_status_verified "verified"
    account_status_closed "closed"

    # ============================================================================
    # Email Configuration
    # ============================================================================
    # Case-insensitive email lookup
    case_insensitive_login true
    # Strip whitespace from email
    login_param "email"

    # ============================================================================
    # Audit Logging (HIPAA Compliance)
    # ============================================================================
    # Enable audit logging for all authentication events
    enable_audit_logging if defined?(RodauthAuditLogging)

    # ============================================================================
    # Routes (not used for API-only, but required for Rodauth config)
    # ============================================================================
    # Skip route generation — we use custom controllers
    skip_status 404 if defined?(skip_status)

    # ============================================================================
    # Session Handling (disabled for JWT API)
    # ============================================================================
    # Disable session handling — use JWT only
    set_notice_flash false
    set_error_flash false
  end
end

# Rodauth account model
class RodauthAccount < Sequel::Model(:accounts)
end
