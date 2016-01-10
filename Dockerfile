FROM ruby

RUN bundle config --global frozen 1
RUN mkdir -p /usr/src/app/lib/xing
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/Gemfile
COPY Gemfile.lock /usr/src/app/Gemfile.lock
COPY xing.gemspec /usr/src/app/xing.gemspec
COPY lib/xing/version.rb /usr/src/app/lib/xing/version.rb
RUN bundle install --without=development

COPY . /usr/src/app

CMD ["bundle", "exec", "bin/run"]
