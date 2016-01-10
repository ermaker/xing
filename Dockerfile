FROM ruby

RUN bundle config --global frozen 1
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN bundle install --without=development

CMD ["bundle", "exec", "bin/run"]

