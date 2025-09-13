class CompleteAllItemsJob < ApplicationJob
  queue_as :default

  def perform(todo_list:)
    return unless todo_list

    incomplete_count = todo_list.todo_list_items.incomplete.count

    return unless incomplete_count > 0

    Rails.logger.info "Starting CompleteAllItemsJob for TodoList ##{todo_list.id}"
    
    todo_list.todo_list_items.incomplete.find_each do |item|
      item.update(is_done: true)
    end
    
    broadcast_notification(todo_list, incomplete_count)
    
    Rails.logger.info "Completed #{incomplete_count} items for TodoList ##{todo_list.id}"
  end

  private

  def broadcast_notification(todo_list, count)
    Turbo::StreamsChannel.broadcast_append_to(
      todo_list,
      target: "notifications",
      partial: "shared/notification",
      locals: { 
        message: "Completed #{count} items of ##{todo_list.id} | #{todo_list.name}", 
        type: "success" 
      }
    )
  end

end