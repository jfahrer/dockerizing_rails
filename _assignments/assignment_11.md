# Assignment 11 - Installing Webpacker

Okay, now let's get webpacker working with rails 5.2.3

## Set up Webpacker

Tasks to complete solution:

- Add the most recent version of webpacker gem as a bundler dependency
- Add yarn via `apk` in the docker image
- Mount a volume for the `node_modules` directory to `/usr/src/app/node_modules`
- Install webpacker by running the rake task: `webpacker:install`
- Navigate to localhost:3000 and open your web console.
- If you see "Hello World from Webpacker!", it worked!
- If you got this far, there are more exercises in the "[Using Webpacker](#using-webpacker)" section

> **Note**: Step-by-step solutions can be found below. All the steps above should excercise previously learned concepts. Give it a shot, then look below for help!

Let's install the most recent version of webpacker by adding it the to the Gemfile.

```
gem 'webpacker', '~> 4.x'
```

Using what we learned from the sidekiq gem installation, let's reinstall.

```
docker-compose run --rm app bundle
```

In order to install webpacker, we'll need to add `yarn` to the Docker image. Add this to the `Dockerfile`

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

And rebuild the image:

```
docker-compose build app
```

Now that we have yarn installed, we can run the `webpacker:install` rails rake task.

```
docker-compose run --rm app bundle exec rails webpacker:install
```

If you run a `git status`, You'll see quite a few files were created and then `yarn install` was run.

But wait! If you look in your root directory you'll notice that a node_modules directory has been installed in your local directory. That's where yarn stores all of it's dependencies defined in the `package.json` – similar to where Bundler stores its gems. It is about 18k files and 120M of `node_modules`. We want to make sure that we don't COPY all those files when we rebuild the image, so think about how you have fixed a similar problem previously.

To clean up, let's remove the `node_modules` directory that was just created (`rm -rf node_modules`).

Add a volume called `node_modules` and mount it to `/usr/src/app/node_modules`.

> **Note**: We have tried many different times to get the node_modules extracted to another directory (e.g. `/usr/local/node_modules`) but it never works properly, unfortunately. So this is second best. Report back if you find a way of doing this.

```yaml
  app:
    volumes:
      - ./:/usr/src/app:cached
      - tmp:/usr/src/app/tmp
      - gems:/usr/local/bundle
      - node_modules:/usr/src/app/node_modules

...

sidekiq:
    volumes:
      - ./:/usr/src/app
      - tmp:/usr/src/app/tmp
      - gems:/usr/local/bundle
      - node_modules:/usr/src/app/node_modules

...

volumes:
  pg-data:
  redis-data:
  tmp:
  gems:
  node_modules:
```

Let’s try booting up the server again.

```
docker-compose up app
```

> **Note**: We’ll see another error. It’s because we removed the node_modules directory – now that we have a volume mounted let’s install those again.

```
docker-compose run --rm app yarn install
```

And let’s boot the server up again.

```
docker-compose up app
```

And also notice on your local disk, the `node_modules` directory exists but now it is empty!

Okay! We also need to revisit the `Dockerfile` to run `yarn install` so that if other engineers on your team pull the app they don’t run into the same yarn install error we just saw.

Add these lines after we install our gems:

```Dockerfile

COPY package.json yarn.lock ./

RUN yarn install

```

```bash
docker-compose build app
```

Okay, now you are all set up and so will other engineers that install the project!

In order to actually load the webpacks that are being generated, found in `app/javascript/packs`, let's add stylesheets and javascript files to the application layout in `application.html.erb`

```erb
    <%= stylesheet_pack_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```

And now if you reload localhost:3000 you'll notice a `console.log` letting you know that webpack compiled assets are being loaded on the page!

## Using Webpacker

Let’s replace EVERYTHING in the asset pipeline with webpacker (starting with bootstrap)

```
docker-compose run --rm app yarn add bootstrap jquery popper.js
```

And also let’s add in rails-ujs and turbolinks.

```
docker-compose run --rm app yarn add rails-ujs turbolinks
```

This adds it to your package.json file, and also locks the dependencies in the yarn.lock file. 


We will need to expose some bootstrap dependencies on the `window` object in javascript, so let's add the following code to `config/webpack/environment.js`

```javascript
const { environment } = require('@rails/webpacker')

const webpack = require("webpack")

environment.plugins.append("Provide", new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))
module.exports = environment
```

And now we can import those dependencies, that facilitates bootstrap, rails-ujs, turbolinks by placing the following code within our `app/javascript/packs/application.js`

```
import "../src/bootstrap_and_rails";
```

Check out the code inside `app/javascript/src/bootstrap_and_rails.js` to see how we're using webpacker.

Now that we've replaced everything in the asset pipeline, we can remove the other javascript and stylesheet imports inside our `application.html.erb` layout.

```
   // Delete me!
    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
```

Now refresh the page and you can see that dark mode is now working! Sprockets has been completely replaced by webpacker now.

# What changed

You can find our changes in the [`webpacker`](~https://github.com/jfahrer/dockerizing_rails/tree/webpacker~) branch. [Compare it](~https://github.com/jfahrer/dockerizing_rails/compare/sidekiq...webpacker~) to the previous branch to see what changed.

[Back to the overview](~../README.md#assignments~)

## Bonus

Notice how each render takes quite a bit of time? Rails is generating those assets when the web request is issued.

We can generate those assets as soon as the javascript is saved using the `./bin/webpack-dev-server` process.

As an exercise for the reader, let’s extract the `bin/webpack-dev-server` process into a separate docker container.

> **Hint**: After running `webpacker:install` this message is presented to the user.

```
You need to allow webpack-dev-server host as allowed origin for connect-src.
This can be done in Rails 5.2+ for development environment in the CSP initializer
config/initializers/content_security_policy.rb with a snippet like this:
policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?
```

> **Super-hint**: [webpacker/docker.md at master · rails/webpacker · GitHub](~https://github.com/rails/webpacker/blob/master/docs/docker.md~)

[Back to the overview](../README.md#assignments)
