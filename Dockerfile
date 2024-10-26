FROM ruby:3.2.2

RUN apt update -qq && apt install -y \
  build-essential \
  nodejs

WORKDIR /eventnxt

RUN gem install bundler -v 2.4.12

COPY . /eventnxt

ENV RAILS_ENV=${RAILS_ENV:-"production"}
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT:-"development:test"}

CMD bash -c "rm -f tmp/pids/server.pid && \
  bundle install && \
  bundle exec rake assets:precompile &&\
  bundle exec rake db:prepare && \
  bundle exec rails s -b 0.0.0.0 -p $PORT"