FROM ruby

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
CMD ["run"]

COPY Gemfile .
COPY xing.gemspec .
RUN mkdir -p lib/xing
COPY lib/xing/version.rb lib/xing/version.rb
RUN bundle install --without=development

COPY . .
RUN rake install:local

