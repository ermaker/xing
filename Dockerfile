FROM ruby

WORKDIR /usr/src/app
COPY Gemfile .
COPY xing.gemspec .
RUN mkdir -p lib/xing
COPY lib/xing/version.rb lib/xing/version.rb
RUN bundle install --without=development

COPY . .
RUN rake install:local

CMD ["run"]
