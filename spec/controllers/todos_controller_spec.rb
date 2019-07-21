require 'rails_helper'

RSpec.describe TodosController, type: :controller do

  let(:valid_attributes) {
    { title: 'laundry'}
  }

  let(:invalid_attributes) {
    { title: '' }
  }

  describe "GET #index" do
    it "returns a success response" do
      Todo.create! valid_attributes
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Todo" do
        expect {
          post :create, params: {todo: valid_attributes}
        }.to change(Todo, :count).by(1)
        expect(response).to redirect_to(todos_path)
      end
    end

    context "with invalid params" do
      it "redirects to the todo list" do
        post :create, params: {todo: invalid_attributes}
        expect(response).to redirect_to(todos_path)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:new_attributes) {
        { completed: true }
      }

      it "updates the requested todo" do
        todo = Todo.create! valid_attributes
        expect(todo.completed).to be_falsy
        patch :update, params: {id: todo.to_param, todo: new_attributes}
        expect(response).to redirect_to(todos_path)
        todo.reload
        expect(todo.completed).to be_truthy
      end
    end

    context "with invalid params" do
      it "redirects to the todos" do
        todo = Todo.create! valid_attributes
        put :update, params: {id: todo.to_param, todo: invalid_attributes}
        expect(response).to redirect_to(todos_path)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested todo" do
      todo = Todo.create! valid_attributes
      expect {
        delete :destroy, params: {id: todo.to_param}
      }.to change(Todo, :count).by(-1)
      expect(response).to redirect_to(todos_path)
    end
  end
end
