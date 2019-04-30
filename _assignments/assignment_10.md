## Assignment 10
This is a collection of various tasks

#### Store gems inside a volume
Ensure that gems are persisted in a volume by mounting it to `/usr/local/bundle`

#### pry / irb history
Keep the pry/irb history locally on your system using a bind mount

#### Synchronizing source code
* ssync/ssync
```
  syncer:
    image: ssync/ssync:0.2.2
    command: watch
    volumes:
      - ./:/src:cached
      - app_src:/dest
      - sync_data:/unison_data
    environment:
      - UNISON_OPTS=-ignore "Path tags*" -ignore "Name {.*,*}.sw[pon]" -ignore "Path tmp/*" -ignore "Path .git" -ignore "Path log/*" -ignore "Path node_modules"
```

#### Run migrations on startup
* Use the `ENTRYPOINT` instruction and define a shell script that will automatically run the migrations if the `MIGRATE` environment variable is true

#### Wait for Postgres
* When we run migrations automatically, we need to ensure that Postgres is already running. The `wait-for-pg` utility is your friend.

#### Build time secrets
* TODO
