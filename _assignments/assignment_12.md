# Keeping gems
We made sure that we don't have to re-install all gems when we make changes to our source code. However, with every change to the `Gemfile`/`Gemfile.lock` we have to re-install all gems again - and waiting for nokogiri to compile can get pretty annoying. It also means that if you switching between branches that use different gems or gem versions, you get stuck in this loop of re-building your Docker Image.

There are some workarounds for this - one of them being: Caching gems locally

All we have to do is mount a volume to `/usr/local/bundle`:
```
services:
  app:
    # -- SNIP --
    volumes:
      - ./:/usr/src/app
      - ${HOME}/.irb-history:/root/.irb-history
      - ${HOME}/.irbrc:/root/.irbrc
      - gems:/usr/local/bundle

# -- SNIP --

volumes:
  gems:
  # -- SNIP --
```


Make sure to mount the `gems` volume to all Rails services (`app`, `web`, `sidekiq`)

When the volume is first created, the content of `/usr/local/bundle` of the Container Image is copied into the volume. After that - it will get stale and we have to manually update the gems. That means after making changes to the Gemfile, we have to run bundle:
```
docker-compose run --rm app bundle
```

The nice thing here is that the volume will contain all the gems that we install over time. So playing around with a new version or switching between branches will be seamless.
