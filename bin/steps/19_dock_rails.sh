# bin/steps/19_dock_rails.sh

cat << 'EOF' > apps/ehr-api/Dockerfile
# apps/ehr-api/Dockerfile
FROM ruby:3.4.8

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]

EOF