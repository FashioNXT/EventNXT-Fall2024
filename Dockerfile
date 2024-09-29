FROM ruby:3.2.2
WORKDIR /eventnxt
RUN apt update -qq && apt install -y \
  build-essential \
  ruby-dev \
  nodejs
COPY . /eventnxt

# Build-time argument (passed using --build-arg)
ARG RAILS_ENV=development

# Runtime environment variables
ENV RAILS_ENV=${RAILS_ENV} 

RUN gem install bundler
RUN bundle install
CMD rails s -b 0.0.0.0 -p $PORT
