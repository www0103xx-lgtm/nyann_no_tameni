FROM ruby:3.4.10

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    libvips \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint

ENTRYPOINT ["./bin/docker-entrypoint"]