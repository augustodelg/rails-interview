class CompleteAllItemsJob < ApplicationJob
  queue_as :default

  def perform(todo_list:)
    return unless todo_list

    incomplete_count = todo_list.todo_list_items.incomplete.count

    if incomplete_count == 0
      broadcast_notification(todo_list, "No incomplete items found for TodoList ##{todo_list.id} | #{todo_list.name}")
      Rails.logger.info "No incomplete items found for TodoList ##{todo_list.id}"
      return
    end

    Rails.logger.info "Starting CompleteAllItemsJob for TodoList ##{todo_list.id}"
    
    todo_list.todo_list_items.incomplete.find_each do |item|
      item.update(completed: true)
    end
    
    broadcast_notification(todo_list, "Completed #{incomplete_count} items of ##{todo_list.id} | #{todo_list.name}")
    
    Rails.logger.info "Completed #{incomplete_count} items for TodoList ##{todo_list.id}"
  end

  private

  def broadcast_notification(todo_list, message)
    Turbo::StreamsChannel.broadcast_append_to(
      todo_list,
      target: "notifications",
      partial: "shared/notification",
      locals: { 
        message: message, 
        type: "success" 
      }
    )
  end

end