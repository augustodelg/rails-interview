module TodoListItems
  class CreateService < ApplicationService
    def initialize(todo_list_id:, params:)
      super()
      @todo_list_id = todo_list_id
      @params = params
      @todo_list = nil
      @todo_list_item = nil
    end

    def call
      begin
        get_todo_list

        create_todo_list_item
        
        if @todo_list_item.save
          set_result(@todo_list_item)
        else
          @todo_list_item.errors.full_messages.each { |error| add_error(error) }
        end
      rescue StandardError => e
        add_error("Error creating the item: #{e.message}")
      ensure
        return self
      end
    end

    private

    def get_todo_list
      @todo_list = TodoList.find_by(id: @todo_list_id)
    end

    def create_todo_list_item
      @todo_list_item = TodoListItem.new(@params.merge(todo_list: @todo_list))
    end

  end
end
