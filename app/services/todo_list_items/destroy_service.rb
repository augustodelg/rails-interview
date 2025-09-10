module TodoListItems
  class DestroyService < ApplicationService
    def initialize(todo_list_id:, todo_list_item_id:)
      super()
      @todo_list_item_id = todo_list_item_id
      @todo_list_id = todo_list_id
      @todo_list_item = nil
    end

    def call
      begin
        find_todo_list_item
        
        if @todo_list_item.destroy
          set_result(@todo_list_item)
        else
          @todo_list_item.errors.full_messages.each { |error| add_error(error) }
        end
        
      rescue StandardError => e
        add_error("Error destroying the item: #{e.message}")
      ensure
        return self
      end
    end

    private

    def find_todo_list_item
      @todo_list_item = TodoListItem.find_by(id: @todo_list_item_id, todo_list_id: @todo_list_id)
      if @todo_list_item.nil?
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end