require 'rails_helper'

RSpec.describe "Todos", type: :request do
  describe 'GET /todos' do
    it 'lists all todos' do
      Todo.create!(title: 'laundry')
      Todo.create!(title: 'shopping)')

      get todos_path

      expect(response).to have_http_status(200)
      expect(response.body).to include("laundry")
      expect(response.body).to include("shopping")
    end
  end
end
