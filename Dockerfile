FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    make \
    gcc \
    libc6-dev \
    chromium \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install ferrum rufus-scheduler -N

COPY honeygain-lucky-pot.rb .

RUN useradd -m honeygain && chown honeygain /app
USER honeygain

CMD ["ruby", "honeygain-lucky-pot.rb"]

