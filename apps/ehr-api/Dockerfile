# apps/ehr-api/Dockerfile
FROM ruby:3.4.8

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

# CMD ["bin/rails", "server", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
