class TodoList < ApplicationRecord
  has_many :todo_list_items, dependent: :destroy

  validates :name, presence: true

  scope :recent, -> { order(created_at: :desc) }
end