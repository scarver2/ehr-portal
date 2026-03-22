# spec/support/auth_helper.rb
# Authentication helpers for testing

module AuthHelper
  # Authenticate API request with JWT token using Rodauth Account
  def auth_headers_for(user)
    token = user.account.generate_jwt_token
    { 'Authorization' => "Bearer #{token}" }
  end

  # Make API request with JWT authentication
  def api_request_with_auth(method, path, user:, **opts)
    headers = auth_headers_for(user).merge(opts[:headers] || {})
    send(method, path, headers: headers, **opts.except(:headers))
  end

  # Make POST API request with JWT authentication
  def post_with_auth(path, user:, **opts)
    api_request_with_auth(:post, path, user: user, **opts)
  end

  # Make GET API request with JWT authentication
  def get_with_auth(path, user:, **opts)
    api_request_with_auth(:get, path, user: user, **opts)
  end

  # Make PUT API request with JWT authentication
  def put_with_auth(path, user:, **opts)
    api_request_with_auth(:put, path, user: user, **opts)
  end

  # Make PATCH API request with JWT authentication
  def patch_with_auth(path, user:, **opts)
    api_request_with_auth(:patch, path, user: user, **opts)
  end

  # Make DELETE API request with JWT authentication
  def delete_with_auth(path, user:, **opts)
    api_request_with_auth(:delete, path, user: user, **opts)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
