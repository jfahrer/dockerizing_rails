require 'rails_helper'

RSpec.describe "Todos", type: :request do
  let(:valid_attributes) {
    { title: 'laundry'}
  }

  let(:invalid_attributes) {
    { title: '' }
  }

  describe 'GET /todos' do
    it 'lists all todos' do
      Todo.create!(title: 'laundry')
      Todo.create!(title: 'shopping')

      get todos_path

      expect(response).to have_http_status(200)
      expect(response.body).to include("laundry")
      expect(response.body).to include("shopping")
    end

    context "with the filter" do
      before do
        Todo.create!(title: 'laundry', completed: false)
        Todo.create!(title: 'shopping', completed: true)
      end

      context "set to completed" do
        it "only returns completed todos" do
          get todos_path, params: { filter: 'completed' }
          expect(response).to have_http_status(200)

          expect(response.body).not_to include("laundry")
          expect(response.body).to include("shopping")
        end
      end

      context "set to active" do
        it "only returns active todos" do
          get todos_path, params: { filter: 'active' }
          expect(response).to have_http_status(200)

          expect(response.body).to include("laundry")
          expect(response.body).not_to include("shopping")
        end
      end

      context "set to all" do
        it "returns all todos" do
          get todos_path, params: { filter: 'all' }
          expect(response).to have_http_status(200)

          expect(response.body).to include("laundry")
          expect(response.body).to include("shopping")
        end
      end
    end
  end

  describe "POST /todos" do
    context "with valid params" do
      it "creates a new Todo" do
        expect {
          post todos_path, params: { todo: valid_attributes }
        }.to change(Todo, :count).by(1)
        expect(response).to redirect_to(todos_path)
      end

      it "creates an entry in the activity log" do
        expect {
          post todos_path, params: { todo: valid_attributes }
        }.to change(Activity, :count).by(1)
      end
    end

    context "with invalid params" do
      it "redirects to the todo list" do
        post todos_path, params: { todo: invalid_attributes }

        expect(response).to redirect_to(todos_path)
      end

      it "does not create an acitivity log entry" do
        expect {
          post todos_path, params: { todo: invalid_attributes }
        }.to_not change { Activity.count }
      end
    end

    context "with a filter set" do
      it "keeps the filter when redirecting" do
        todo = Todo.create! valid_attributes

        post todos_path, params: { filter: "active", todo: valid_attributes }

        expect(response).to redirect_to(todos_path(filter: "active"))
      end
    end
  end

  describe "PATCH /todos/:id" do
    context "with valid params" do
      let(:new_attributes) {
        { completed: true }
      }

      it "updates the requested todo" do
        todo = Todo.create! valid_attributes
        expect(todo.completed).to be_falsy

        patch todo_path(todo), params: { id: todo.to_param, todo: new_attributes }
        todo.reload

        expect(response).to redirect_to(todos_path)
        expect(todo.completed).to be_truthy
      end

      it "creates an entry in the activity log" do
        todo = Todo.create! valid_attributes

        expect {
          patch todo_path(todo), params: { id: todo.to_param, todo: new_attributes }
        }.to change(Activity, :count).by(1)
      end
    end

    context "with invalid params" do
      it "redirects to the todos" do
        todo = Todo.create! valid_attributes

        patch todo_path(todo), params: { id: todo.to_param, todo: invalid_attributes }
        expect(response).to redirect_to(todos_path)

      end

      it "does not create an acitivity log entry" do
        todo = Todo.create! valid_attributes

        expect {
          patch todo_path(todo), params: { id: todo.to_param, todo: invalid_attributes }
        }.to_not change { Activity.count }
      end
    end

    context "with a filter set" do
      it "keeps the filter when redirecting" do
        todo = Todo.create! valid_attributes

        patch todo_path(todo), params: { filter: "active", id: todo.to_param, todo: invalid_attributes }

        expect(response).to redirect_to(todos_path(filter: "active"))
      end
    end
  end

  describe "DELETE /todos/:id" do
    it "destroys the requested todo" do
      todo = Todo.create! valid_attributes

      expect {
        delete todo_path(todo), params: { id: todo.to_param }
      }.to change(Todo, :count).by(-1)
      expect(response).to redirect_to(todos_path)
    end

    it "creates an entry in the activity log" do
      todo = Todo.create! valid_attributes

      expect {
        delete todo_path(todo), params: { id: todo.to_param }
      }.to change(Activity, :count).by(1)
    end

    context "with a filter set" do
      it "keeps the filter when redirecting" do
        todo = Todo.create! valid_attributes

        delete todo_path(todo), params: { filter: "active", id: todo.to_param }

        expect(response).to redirect_to(todos_path(filter: "active"))
      end
    end
  end
end
