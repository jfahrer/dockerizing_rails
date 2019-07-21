FROM jfahrer/ruby:2.6.3-alpine3.10-ser

RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev

RUN gem install bundler:2.0.2

WORKDIR /usr/src/app

COPY . .

RUN bundle install

CMD ["rails", "console"]
