class TodosController < ApplicationController
  before_action :set_todo, only: [:update, :destroy]
  after_action :update_scores, only: [:create, :update, :destroy]

  # GET /todos
  def index
    @todos = Todo.public_send(current_filter || :all_todos).ordered
  end

  # POST /todos
  def create
    @todo = Todo.new(create_params)
    if @todo.save
      Activity.create(name: "todo_created", data: {id: @todo.id, title: @todo.title})
    end

    redirect_to todos_path(filter: current_filter)
  end

  # PATCH/PUT /todos/1
  def update
    if @todo.update(update_params) && @todo.completed_previously_changed?
      activity_name = @todo.completed ? "todo_marked_as_complete" : "todo_marked_as_active"
      Activity.create(name: activity_name, data: {id: @todo.id, title: @todo.title})
    end

    respond_to do |format|
      format.html { redirect_to todos_path(filter: current_filter) }
      format.js
    end
  end

  # DELETE /todos/1
  def destroy
    if @todo.destroy
      Activity.create(name: "todo_deleted", data: {id: @todo.id, title: @todo.title})
    end

    redirect_to todos_url(filter: current_filter)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todo
    @todo = Todo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def create_params
    params.require(:todo).permit(:title)
  end

  def update_params
    params.require(:todo).permit(:completed)
  end

  def update_scores
    ScoreCalculator.call(Date.today)
  end

  def current_filter
    @filter ||= begin
                  filter = params[:filter]
                  allowed_filters = ["active", "completed"]
                  allowed_filters.include?(filter) ? filter : nil
                end
  end

  helper_method :current_filter
end
