require 'rails_helper'

RSpec.describe Activity, type: :model do
  context "callbacks" do
    context "with sidekiq enabled" do
      before do
        stub_const('SIDEKIQ_ENABLED', true)
      end

      it "enqueues a job to update the progress" do
        Sidekiq::Testing.fake! do
          book = Book.create(title: "Foo", pages: 20)
          expect do
            book.activities.create(pages_read: 5)
          end.to change(ProgressUpdateJob.jobs, :size).by(1)
        end
      end
    end

    context "with sidekiq disabled" do
      before do
        stub_const('SIDEKIQ_ENABLED', false)
      end

      it "does not enqueue a job" do
        Sidekiq::Testing.fake! do
          book = Book.create(title: "Foo", pages: 20)
          expect do
            book.activities.create(pages_read: 5)
          end.not_to change(ProgressUpdateJob.jobs, :size)
        end
      end
    end
  end
end
