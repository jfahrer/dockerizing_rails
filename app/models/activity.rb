class Activity < ApplicationRecord
  belongs_to :book

  validates :book, presence: true
  validates :pages_read, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  after_save :update_progress

  private

  def update_progress
    if SIDEKIQ_ENABLED
      ProgressUpdateJob.perform_async(book_id)
    end
  end
end
