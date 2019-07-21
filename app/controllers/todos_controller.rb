class TodosController < ApplicationController
  before_action :set_todo, only: [:update, :destroy]

  # GET /todos
  def index
    @todos = Todo.all
  end

  # POST /todos
  def create
    @todo = Todo.new(todo_params)

    @todo.save
    redirect_to todos_path
  end

  # PATCH/PUT /todos/1
  def update
    @todo.update(todo_params)
    redirect_to todos_path
  end

  # DELETE /todos/1
  def destroy
    @todo.destroy
    redirect_to todos_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def todo_params
      params.require(:todo).permit(:title, :completed)
    end
end
