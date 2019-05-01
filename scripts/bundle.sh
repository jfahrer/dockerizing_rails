#!/bin/bash
set -e
docker-compose run --rm app bundle install
docker-compose restart app web sidekiq
