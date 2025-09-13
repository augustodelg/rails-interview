class TodoListItem < ApplicationRecord  
  belongs_to :todo_list

  validates :description, presence: true
  validates :completed, inclusion: { in: [true, false] }

  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :recent, -> { order(created_at: :desc) }

  after_update_commit lambda {
    broadcast_replace_to todo_list
  }

end
