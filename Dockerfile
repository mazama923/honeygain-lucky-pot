# ---- Builder ----
FROM ruby:3.3-slim AS builder

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  build-essential \
  make \
  gcc \
  libc6-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install ferrum rufus-scheduler -N

# ---- Runtime ----
FROM ruby:3.3-slim

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  chromium \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

COPY honeygain_lucky_pot.rb .

RUN useradd -m honeygain && chown honeygain /app
USER honeygain

CMD ["ruby", "honeygain_lucky_pot.rb"]

