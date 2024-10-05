FROM ruby:3.2.2
WORKDIR /eventnxt
RUN apt update -qq && apt install -y \
  build-essential \
  ruby-dev \
  nodejs
COPY . /eventnxt

ENV RAILS_ENV production

RUN gem install bundler
RUN bundle install
CMD bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0 -p $PORT"
