FROM ruby

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN rake install

CMD ["run"]
