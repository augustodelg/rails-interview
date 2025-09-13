class TodoListItem < ApplicationRecord
  include ActionView::RecordIdentifier
  
  belongs_to :todo_list

  validates :description, presence: true
  validates :is_done, inclusion: { in: [true, false] }

  broadcasts_to :todo_list
  
  after_create_commit -> { 
    broadcast_append_to todo_list, target: "todo_list_#{todo_list.id}_items",
                       partial: "todo_list_items/todo_list_item", 
                       locals: { todo_list_item: self }
  }

  scope :incomplete, -> { where(is_done: false) }
end
