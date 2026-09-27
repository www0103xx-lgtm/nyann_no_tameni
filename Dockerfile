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

RUN SECRET_KEY_BASE_DUMMY=1 \
    BREVO_SMTP_LOGIN=dummy \
    BREVO_SMTP_KEY=dummy \
    RAILS_ENV=production \
    bin/rails assets:precompile

ENTRYPOINT ["./bin/docker-entrypoint"]

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
