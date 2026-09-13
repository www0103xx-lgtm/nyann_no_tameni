FROM ruby:3.4.10

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    libvips \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint

ENTRYPOINT ["./bin/docker-entrypoint"]

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]