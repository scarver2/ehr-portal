# syntax=docker/dockerfile:1.7

############################
# Base image
############################
FROM ruby:4.0.2-slim AS base

WORKDIR /app

ENV RAILS_ENV=production \
  BUNDLE_DEPLOYMENT=1 \
  BUNDLE_PATH=/usr/local/bundle \
  BUNDLE_WITHOUT="development test" \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  PATH="/usr/local/bundle/bin:${PATH}"

############################
# Builder image
############################
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  build-essential \
  git \
  curl \
  pkg-config \
  nodejs \
  libpq-dev \
  libyaml-dev \
  && rm -rf /var/lib/apt/lists/*

# Install gems with build cache
COPY Gemfile Gemfile.lock ./

RUN --mount=type=cache,target=/usr/local/bundle/cache \
  bundle install && \
  rm -rf /usr/local/bundle/ruby/*/cache \
  /usr/local/bundle/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile Bootsnap caches
RUN bundle exec bootsnap precompile --gemfile
RUN bundle exec bootsnap precompile app/ lib/

# Compile SCSS and precompile assets for production
RUN SECRET_KEY_BASE=placeholder \
  DB_HOST=placeholder \
  bundle exec rails dartsass:build assets:precompile

############################
# Runtime image
############################
FROM ruby:4.0.2-slim AS runtime

WORKDIR /app

ENV RAILS_ENV=production \
  BUNDLE_DEPLOYMENT=1 \
  BUNDLE_PATH=/usr/local/bundle \
  BUNDLE_WITHOUT="development test" \
  PATH="/usr/local/bundle/bin:${PATH}"

# Install runtime dependencies only
RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  libpq5 \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Copy gems and app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Default Rails port
EXPOSE 3000

# Run Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
