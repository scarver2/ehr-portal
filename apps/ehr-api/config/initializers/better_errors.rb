# config/initializers/better_errors.rb
# frozen_string_literal: true

# Allow BetterErrors from any loopback address so the error page is reachable
# from the Next.js portal (localhost:3001) and browser dev tools alike.

if defined?(BetterErrors)
  BetterErrors::Middleware.allow_ip! "127.0.0.0/8"
  BetterErrors::Middleware.allow_ip! "::1"
end
