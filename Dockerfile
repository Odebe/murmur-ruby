FROM ruby:3.2.2

COPY Gemfile Gemfile.lock ./

RUN bundle install -j $(nproc)

WORKDIR /app
COPY . /app

