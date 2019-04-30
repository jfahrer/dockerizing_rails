FROM jfahrer/ruby:2.5.5-alpine3.9-railsconf

RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev

RUN gem install bundler:2.0.1

WORKDIR /usr/src/app

COPY . .

RUN bundle install

CMD ["rails", "console"]
