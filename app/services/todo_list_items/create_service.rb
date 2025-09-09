module TodoListItems
  class CreateService < ApplicationService
    attr_reader :todo_list_item_params, 
                :todo_list_id

    def initialize(todo_list_id, todo_list_item_params)
      @todo_list_id = todo_list_id
      @todo_list_item_params = todo_list_item_params
    end

    def call
      begin
        debugger
        find_todo_list
        
        @todo_list_item = TodoListItem.create(todo_list_item_params.merge(todo_list: todo_list))
        set_result(@todo_list_item)

      rescue StandardError => e
        add_error(e.message)

      ensure
        self
      end
    end

    private

    def find_todo_list
      @todo_list = TodoList.find(id: todo_list_id)
    end
  end
end