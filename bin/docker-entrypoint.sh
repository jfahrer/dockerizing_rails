#!/usr/bin/env bash
if [ "$WAIT_FOR_POSTGRES" == "true" ]; then
  echo -n Waiting for postgres to start...
  while ! pg_isready -h ${POSTGRES_HOST:-localhost} > /dev/null; do
    sleep 0.5; echo -n .; done
  echo done
fi
if [ "$PREPARE_DATABASE" == "true" ]; then
  bundle exec rake db:create db:migrate
fi

exec "$@"
