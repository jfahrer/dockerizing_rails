# Assignment 9 - Debugging

Now that we can iterate quickly on our application, it is time to fix the failing spec!

Let's look at the out output of the spec:
```
  1) Todos PATCH /todos/:id with valid params creates an entry in the activity log
     Failure/Error:
       expect {
         patch todo_path(todo), params: {id: todo.to_param, todo: new_attributes}
       }.to change(Activity, :count).by(1)

       expected `Activity.count` to have changed by 1, but was changed by 0
     # ./spec/requests/todos_spec.rb:123:in `block (4 levels) in <main>'
```

We can confirm this is an actual problem by
* Opening the browser and heading to http://localhost:3000
* Creating a todo
* Marking the todo as complete
* Heading to the activity log

We can see that we only have an entry for the creation of our todo, not for marking it as complete.

## What now?
One way to troubleshoot this problem is to use a debugger. Let's open the file `./app/controllers/todos_controller.rb` and place a `byebug` in the first line of the `update` action:

```
  # PATCH/PUT /todos/1
  def update
    byebug
    if @todo.update(update_params) && @todo.completed_changed?
      activity_name = @todo.completed ? "todo_marked_as_complete" : "todo_marked_as_active"
    ...
```



But before we make the change, let's try to get a byebug session from an actual web request. Todo that we need to switch back to our browser and make a todo as completed or active.


TODO
```
docker-compose stop app
docker-compose run --rm --service-ports app
```

    tty: true
    stdin_open: true
    docker-compose ps
    docker container attach dockerizing_rails_app_1

    TODO: Sequence to detach
