class Activity < ApplicationRecord
  VALID_NAMES = %w[todo_marked_as_complete todo_marked_as_active todo_created todo_deleted]
  serialize :data, Hash

  validates :name, inclusion: {in: VALID_NAMES}
end
