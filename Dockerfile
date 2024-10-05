FROM ruby:3.2.2
WORKDIR /eventnxt
RUN apt update -qq && apt install -y \
  build-essential \
  ruby-dev \
  nodejs
COPY . /eventnxt

ENV RAILS_ENV=${RAILS_ENV:-"production"}
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT:-"development:test"}

RUN gem install bundler

CMD bash -c "rm -f tmp/pids/server.pid && \
  bundle install && \
  bundle exec rake assets:precompile &&\
  bundle exec rails db:prepare && \
  bundle exec rails s -b 0.0.0.0 -p $PORT"