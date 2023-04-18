FROM ruby:3.2-alpine

RUN apk update && apk --no-cache add build-base

ENV BOT_ENV="production"
ENV RACK_ENV="production"
ENV RACK_ROOT="/var/www/bot"
ENV TZ="Europe/Berlin"

RUN mkdir -p $RACK_ROOT
WORKDIR $RACK_ROOT
COPY . .
RUN bundle config set without 'development test' && \
  bundle install --jobs 20 --retry 5
