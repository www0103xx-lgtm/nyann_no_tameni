FROM ruby:3.4.10

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile /app/Gemfile

RUN bundle install

COPY . /app
