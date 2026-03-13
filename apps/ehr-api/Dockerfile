
FROM ruby:4.0.1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
