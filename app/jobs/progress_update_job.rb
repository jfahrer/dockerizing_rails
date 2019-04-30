class ProgressUpdateJob
  include Sidekiq::Worker
  def perform(book_id)
    book = Book.find(book_id)
    read = book.activities.sum(:pages_read)
    progress = (100.0 / book.pages * read).round
    book.update!(progress: progress)
  end
end
