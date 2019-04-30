require 'rails_helper'

RSpec.describe Book, type: :model do
  context "validations" do
    it "ensures that the title is present" do
      book = Book.new(title: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to be_present
    end
  end
end
