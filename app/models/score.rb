class Score < ApplicationRecord
  validates :date, :points, presence: true
end
