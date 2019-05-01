FROM jfahrer/ruby:2.5.5-alpine3.9-railsconf

RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev \
      postgresql

RUN gem install bundler:2.0.1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENV PATH=./bin:$PATH

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint.sh"]
CMD ["rails", "console"]
