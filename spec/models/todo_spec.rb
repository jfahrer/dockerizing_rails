require 'rails_helper'

RSpec.describe Todo, type: :model do
  it "requires a title" do
    todo = Todo.create(title: nil)
    expect(todo).not_to be_valid
  end
end
