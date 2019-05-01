#/bin/bash
set -e
VOLUMES_TO_DELETE="app_src gems sync_data"
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-$(basename $(pwd) | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')}

echo "Building images"
docker-compose build --pull app

echo "Shutting down any running services"
docker-compose down

if [ -n "$RESET" ] && [ "$RESET" != "false" ]; then
  # We remove all volumes here to fully reset the system
  echo "Deleting all volumes"
  docker-compose down -v
else
  # Just remove the volumes holding the source and libraries
  echo "Deleting the volumes ${VOLUMES_TO_DELETE}"
  for volume_name in $VOLUMES_TO_DELETE; do
    docker volume rm ${COMPOSE_PROJECT_NAME}_${volume_name} || true
  done
fi

echo "Synchronizing source code"
docker-compose run --rm syncer run

echo "Starting required services"
docker-compose up -d syncer pg redis

echo "Updating libraries"
docker-compose run --rm app bundle

if [ -n "$RESET" ] && [ "$RESET" != "false" ]; then
  echo "Creating and seeding database"
  docker-compose run --rm -e WAIT_FOR_POSTGRES=true app rake db:create db:migrate
  docker-compose run --rm app rake db:seed
fi

echo "Starting all services"
docker-compose up -d
docker-compose ps
