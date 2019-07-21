class Todo < ApplicationRecord
  scope :completed, -> { where(archived_at: nil, completed: true) }
  scope :active, -> { where(archived_at: nil, completed: false) }

  validates :title, presence: true

  def title=(title)
    write_attribute(:title, title.to_s.strip)
  end
end
