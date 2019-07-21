class Todo < ApplicationRecord
  scope :completed, -> { where(completed: true) }
  scope :active, -> { where(completed: false) }

  validates :title, presence: true

  def title=(title)
    write_attribute(:title, title.to_s.strip)
  end
end
