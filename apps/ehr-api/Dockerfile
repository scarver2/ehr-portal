# apps/ehr-api/Dockerfile

############################################
# Base image
############################################

FROM ruby:3.4.8-slim AS base

ENV RAILS_ENV=production \
  BUNDLE_DEPLOYMENT=1 \
  BUNDLE_PATH=/usr/local/bundle \
  BUNDLE_WITHOUT="development test"

WORKDIR /app

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  git \
  curl \
  pkg-config \
  nodejs \
  && rm -rf /var/lib/apt/lists/*


############################################
# Gems
############################################

FROM base AS gems

COPY Gemfile Gemfile.lock ./

RUN bundle install && \
  rm -rf ~/.bundle \
  $BUNDLE_PATH/ruby/*/cache \
  $BUNDLE_PATH/ruby/*/bundler/gems/*/.git


############################################
# Build app
############################################

FROM base AS build

COPY --from=gems /usr/local/bundle /usr/local/bundle

COPY . .

RUN bundle exec bootsnap precompile --gemfile
RUN bundle exec bootsnap precompile app/ lib/


############################################
# Final runtime image
############################################

FROM ruby:3.4.8-slim

WORKDIR /app

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  libpq5 \
  curl \
  && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
