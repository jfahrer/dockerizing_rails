require 'rails_helper'

RSpec.describe "Todos", type: :request do
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
end
