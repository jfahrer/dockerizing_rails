class ArchivedTodosController < ApplicationController
  def create
    Todo.completed.update_all(archived_at: Time.now)

    redirect_to todos_path
  end
end
