FROM ruby:4.0.1-slim AS runtime
WORKDIR /app

ENV BUNDLE_WITHOUT="development test"
ENV BUNDLE_PATH="/usr/local/bundle"
#ENV BUNDLE_DEPLOYMENT=true

FROM ruby:4.0.1 AS builder
RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libclang-dev \
  && rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- \
  --profile minimal \
  --default-toolchain stable \
  -y

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set --global deployment true \
 && bundle config set --global without 'development test' \
 && bundle config set --global path /usr/local/bundle \
 && bundle config set --global clean true

RUN bundle install --jobs=$(nproc) --retry=3

COPY . .

FROM runtime
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

CMD ["bundle", "exec", "ruby", "bin/server.rb"]
