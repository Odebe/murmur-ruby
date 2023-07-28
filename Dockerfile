FROM ruby:3.2.2

RUN mkdir /rust
WORKDIR /rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --profile minimal --default-toolchain stable -y
WORKDIR /
ENV PATH=/root/.cargo/bin:$PATH

RUN apt-get update && apt-get install -y libclang-dev

COPY Gemfile Gemfile.lock ./

RUN bundle config set --local without 'test development'
RUN bundle install -j $(nproc)

WORKDIR /app
COPY . /app

