require "rails_helper"

RSpec.describe "ArchivedTodos", type: :request do
  describe "POST /archived_todos" do
    it "archives all complted todos" do
      completed_todos = [
        Todo.create(title: "laundry", completed: true),
        Todo.create(title: "shopping", completed: true),
      ]
      active_todo = Todo.create(title: "cleaning", completed: false)

      post archived_todos_path
      expect(response).to redirect_to(todos_path)

      expect(completed_todos.each(&:reload).map(&:archived_at)).not_to include(nil)
      expect(active_todo.reload.archived_at).to be_nil
    end
  end
end
