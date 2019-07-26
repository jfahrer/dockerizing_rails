class Todo < ApplicationRecord
  scope :ordered, -> { order(id: :asc) }
  scope :completed, -> { where(archived_at: nil, completed: true) }
  scope :active, -> { where(archived_at: nil, completed: false) }
  scope :all_todos, -> { where(archived_at: nil) }

  validates :title, presence: true

  def title=(title)
    write_attribute(:title, title.to_s.strip)
  end
end
