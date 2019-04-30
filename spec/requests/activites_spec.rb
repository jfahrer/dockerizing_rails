require 'rails_helper'

RSpec.describe "Activites" do
  describe 'POST /activities' do
    it "logs the activity" do
      book = Book.create!(title: "Some book", pages: 500)
      params =  { book_id: book.id, pages_read: 125 }
      expect { post activities_path, params: { activity: params } }.to change { book.activities.count }.by(1)
    end
  end
end
