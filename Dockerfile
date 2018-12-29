FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y build-essential default-libmysqlclient-dev nodejs
RUN mkdir /labici
WORKDIR /labici
ADD Gemfile /labici/Gemfile
ADD Gemfile.lock /labici/Gemfile.lock
RUN bundle install
ADD . /labici
