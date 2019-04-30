require 'rails_helper'

RSpec.describe ProgressUpdateJob do
  describe '#peform' do
    it "updates the progress of the book" do
      book = Book.create(title: "Foobar", pages: 500)
      book.activities.create(pages_read: 125)
      book.activities.create(pages_read: 125)

      expect { described_class.new.perform(book.id) }.to change { book.reload.progress }.from(nil).to(50)
    end

    it "sets the progress to 100 if there are more read pages than pages" do
      book = Book.create(title: "Foobar", pages: 500)
      book.activities.create(pages_read: 125)
      book.activities.create(pages_read: 450)

      expect { described_class.new.perform(book.id) }.to change { book.reload.progress }.from(nil).to(100)
    end
  end
end
