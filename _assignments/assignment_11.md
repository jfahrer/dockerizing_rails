Okay, now let's get webpacker working with rails 5.2.3

Let's install the most recent version of webpacker by adding it the to the Gemfile.

```
gem 'webpacker', '~> 4.x'
```

Using what we learned from the sidekiq gem installation, let's reinstall.

```
docker-compose run --rm app bundle
```

Now run the `webpacker:install` rails rake task.

```
docker-compose run --rm app bundle exec rails webpacker:install
```

Looks like yarn is not installed! Let's install yarn by changing the `Dockerfile`

```
RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev \
      yarn
```

And now you'll need to rebuild the app container

```
docker-compose build app
```

We can rerun the `webpacker:install` task now that yarn is installed.

```
docker-compose run --rm app bundle exec rails webpacker:install
```

You'll see some files created (including some in the bin directory that we will want to run soon) and a `yarn install` run.

But wait! If you look in your root directory you'll notice that a node_modules directory has been installed in your local directory. It is about 18k files and 120M of `node_modules`. We want to make sure that we don't COPY all those files when we rebuild the image, so think about how you have fixed a similar problem previously.

First let's remove the node_modules directory that was just created (`rm -rf node_modules`).

Add a volume called `node_modules` and mount it to `/usr/src/app/node_modules`.

```yaml
  app:
    volumes:
      - ./:/usr/src/app:cached
      - gems:/usr/local/bundle
      - node_modules:/usr/src/app/node_modules

...

sidekiq:
    volumes:
      - ./:/usr/src/app:cached
      - gems:/usr/local/bundle
      - node_modules:/usr/src/app/node_modules

...

volumes:
  pg-data:
  gems:
  node_modules:
```

Okay! We also need to revise the `Dockerfile` to run `yarn install`. Add these lines after we install our gems.

```Dockerfile

COPY package.json yarn.lock ./

RUN yarn install

```

Now rebuild the image, and you should notice that the node_modules directory is no longer full of files.

```bash
docker-compose build app
```

In order to actually load the webpacks that are being generated (now application.js within `app/javascripts/packs`), let's add stylesheets and javascript files to use packs.

```haml
    <%= stylesheet_pack_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```

And now if you reload localhost:3000 you'll notice a console.log letting you know that webpack compiled assets are being loaded on the page!

TODO: Use webpacker to modify the DOM (light mode / dark mode? ajax request?)

## Homework:

Notice how each render takes quite a bit of time? Rails is generating those assets when the web request is happening.

As an excercise for the reader, let's extract the bin/webpack-dev-server process into a separate docker container.

We can generate those assets as soon as the javascript is saved, as long as we get smart about how we watch it.

Let's modify the `docker-compose.yml` script to run the `bin/webpack-dev-server` so it will quickly regenerate files.
