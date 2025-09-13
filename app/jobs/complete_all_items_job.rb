class CompleteAllItemsJob < ApplicationJob
  queue_as :default

  def perform(todo_list_id)
    todo_list = TodoList.find_by(id: todo_list_id)
    return unless todo_list

    Rails.logger.info "Starting CompleteAllItemsJob for TodoList ##{todo_list_id}"
    
    todo_list.todo_list_items.incomplete.find_each do |item|
      item.update(is_done: true)
    end
    
    Rails.logger.info "Completed items for TodoList ##{todo_list_id}"
  end

  private

  # def broadcast_update(todo_list)
  #   begin
  #     todo_list.todo_list_items.reload
  #     Rails.logger.info "Broadcasting update for TodoList ##{todo_list.id}"
      
  #     Turbo::StreamsChannel.broadcast_action_to(
  #       "todo_list_#{todo_list.id}",
  #       action: :replace,
  #       target: "todo_list_#{todo_list.id}_items",
  #       partial: "shared/todo_list_items",
  #       locals: { todo_list: todo_list }
  #     )
      
  #     Rails.logger.info "Successfully broadcasted items update for TodoList ##{todo_list.id}"
      
  #     Turbo::StreamsChannel.broadcast_action_to(
  #       "todo_list_#{todo_list.id}",
  #       action: :append,
  #       target: "notifications",
  #       html: '<div class="notification success" data-turbo-temporary style="padding: 10px; background: green; color: white; margin: 10px;">All items completed! ✅</div>'
  #     )
      
  #     Rails.logger.info "Successfully broadcasted notification for TodoList ##{todo_list.id}"
      
  #   rescue => e
  #     Rails.logger.error "Error broadcasting update for TodoList ##{todo_list.id}: #{e.message}"
  #     Rails.logger.error e.backtrace.join("\n")
  #   end
  # end

end