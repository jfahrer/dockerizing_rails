# Assignment 9 - Debugging

Now that we can iterate quickly on our application, it is time to fix the failing spec!

Let's rerun the specs with `docker-compose run --rm app rspec spec/` and look at the error message for the failing spec:
```
  1) Todos PATCH /todos/:id with valid params creates an entry in the activity log
     Failure/Error:
       expect {
         patch todo_path(todo), params: {id: todo.to_param, todo: new_attributes}
       }.to change(Activity, :count).by(1)

       expected `Activity.count` to have changed by 1, but was changed by 0
     # ./spec/requests/todos_spec.rb:123:in `block (4 levels) in <main>'
```

It tells us that updating a todo (e.g. marking a todo as complete) does not create an entry in our activity log. We can confirm this is an actual problem by:
* Opening the browser and heading to http://localhost:3000
* Creating a todo
* Marking the todo as complete
* Heading to the activity log

In the activity log we can see that we only have an entry for the creation of our todo but not for marking it as complete.

## What now?
One way to troubleshoot this problem is to use a debugger like `byebug`. Let's open the file `./app/controllers/todos_controller.rb` and place a `byebug` in the first line of the `update` action:

```
  # PATCH/PUT /todos/1
  def update
    byebug
    if @todo.update(update_params) && @todo.completed_changed?
      activity_name = @todo.completed ? "todo_marked_as_complete" : "todo_marked_as_active"
    ...
```

If we now rerun the failing spec with `docker-compose run --rm app rspec ./spec/requests/todos_spec.rb:123` we will be presented with a `byebug` prompt:

```
Run options: include {:locations=>{"./spec/requests/todos_spec.rb"=>[123]}}

[18, 27] in /usr/src/app/app/controllers/todos_controller.rb
   18:   end
   19:
   20:   # PATCH/PUT /todos/1
   21:   def update
   22:     byebug
=> 23:     if @todo.update(update_params) && @todo.completed_changed?
   24:       activity_name = @todo.completed ? "todo_marked_as_complete" : "todo_marked_as_active"
   25:       Activity.create(name: activity_name, data: {id: @todo.id, title: @todo.title})
   26:     end
   27:
```

If we execute the individual parts of the conditional, we can see that `@todo.update(update_params)` returns `true` but `@todo.completed_changed?` returns `false`. The `update_params` however contain `{"completed"=>"true"}` and we know the todo was not completed prior based on our test setup. So the issue must be withing the `@todo.completed_changed?`. If we inspect `@todo.changes` we get back an empty hash which indicates that there are no changes.

```
Run options: include {:locations=>{"./spec/requests/todos_spec.rb"=>[123]}}

[18, 27] in /usr/src/app/app/controllers/todos_controller.rb
   18:   end
   19:
   20:   # PATCH/PUT /todos/1
   21:   def update
   22:     byebug
=> 23:     if @todo.update(update_params) && @todo.completed_changed?
   24:       activity_name = @todo.completed ? "todo_marked_as_complete" : "todo_marked_as_active"
   25:       Activity.create(name: activity_name, data: {id: @todo.id, title: @todo.title})
   26:     end
   27:
(byebug) @todo.update(update_params)
true
(byebug) @todo.completed_changed?
false
(byebug) update_params
<ActionController::Parameters {"completed"=>"true"} permitted: true>
(byebug) @todo.changes
{}
```

This happens because the `update` call actually persists the changes to the database and also clears the `changes` hash. That makes sense because we now deal with a fully persisted todo again. However, Rails also gives us `@todo.previous_changes`! In the previous changes we can see that `completed` changes from `false` to `true`.
```
(byebug) @todo.previous_changes
{"completed"=>[false, true], "updated_at"=>[Fri, 26 Jul 2019 16:37:47 UTC +00:00, Fri, 26 Jul 2019 16:37:51 UTC +00:00]}
```

That means that `@todo.completed_previously_changed?` should return true - and it does.
```
(byebug) @todo.completed_previously_changed?
true
```

To make our test pass we can simply replace `@todo.completed_changed?` with `@todo.completed_previously_changed?`.

But before we make the change, let's try to get a `byebug` session from an actual web request. To do that we need to switch back to our browser and make a todo as completed or active.

What should happen is that the Rails server stop and opens a `byebug` - but as you can tell, this doesn't work. The request is processed and http response is returned to our browser. This happens because by default the contains that are started with `docker-compose up` (as well as `docker-compose start` and `docker-compose restart`) don't have a tty attached and `byebug` can't hence not start the session.

We've seen that opening a byebug session works when we use `docker-compose run`. It does because Docker Compose will automatically attach a pseudo-tty for us and attach `STDIN` as well. So let's start the Rails server with `docker-compose run` instead. We have to first shut down the current app service, otherwise we will not be able to start a new Rails server because port 3000 is already in use.
```
docker-compose stop app
```

Now we can start the Rails server witch `docker-compose run`:
```
docker-compose run --rm -p 127.0.0.1:3000:3000 app
```

Since we defined the port mapping in our `docker-compose.yml` and `rails server` we could also use the `--service-ports` flag instead of `-p`:
```
docker-compose run --rm --service-ports app
```

If we now mark another todo as complete or active we will be dropped into a `byebug` session.

We already know how to fix the issue. Go ahead and make the code change and make sure that the test passes.

## Making it work without stopping the server
Depending on your style of working, starting and stopping the container whenever we want to start a `byebug` session might be tedious. The good news is that there is another way! We can add the following settings to our `app` service definition in the `docker-compose.yml`:

```yaml
    tty: true
    stdin_open: true
```

These to flags do what `docker-compose run` does for us automatically: They will attach a pseudo-tty to the container and keep `STDIN` open. You can find a complete example in `_examples/docker-compose.yml.with_tty`.

With these flags in place we can now restart our containers with
```
docker-compose up -d
```

If we now place another byebug in the controller action and update a todo, we will see that the browser hangs. We can also see that a `byebug` session was opened if we run
```
docker-compose logs --tail 25 app
```

The question is, how can we get into the session so that we can start typing commands? The answer is *by attaching to the container*. We can use the `docker attach` command to do that.

We first need to find the name of the running container with
```
docker-compose ps
```

In the output we will copy the name of the container for the `app` service - `dockerizing_rails_app_1` in our case:
```
Name                        Command               State            Ports
-------------------------------------------------------------------------------------------
dockerizing_rails_app_1   rails server -b 0.0.0.0 -- ...   Up      127.0.0.1:3000->3000/tcp
dockerizing_rails_pg_1    docker-entrypoint.sh postgres    Up      5432/tcp
```

Now that we have the container we can attach to it:
```
docker attach dockerizing_rails_app_1
```

And there we go! If you press `ENTER` you will see that you are in a `byebug` session, just as before.

If we end the session by typing `continue`, we will see the Rails log on our screen - we are still attached to the container. In order to detach from the container we can use the key sequence `Ctrl-p` `Ctrl-q`. We could also press `Ctrl-c`, but that would terminate the container and we would have to restart the service.

__*Side note*__: The naming conventions of Docker Compose makes it pretty straight forward to "guess". I also recommend using command-line completion for Docker and [Docker compose](https://docs.docker.com/compose/completion/)

# What changed
You can find our changes in the [`debugging`](https://github.com/jfahrer/dockerizing_rails/tree/debugging) branch. [Compare it](https://github.com/jfahrer/dockerizing_rails/compare/iterating...debugging) to the previous branch to see what changed.

[Back to the overview](../README.md#assignments)
