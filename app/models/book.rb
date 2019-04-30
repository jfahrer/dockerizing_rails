class Book < ApplicationRecord
  has_many :activities, dependent: :destroy

  validates :title, presence: true
  validates :pages, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
