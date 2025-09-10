module TodoLists
  class GetAllServices < ApplicationService
    def initialize
      super()
      @todo_lists = nil
    end

    def call
      begin
        get_todo_lists
        
        set_result(@todo_lists)
        
      rescue StandardError => e
        add_error("Error getting all todo lists: #{e.message}")
      ensure
        return self
      end
    end

    private

    def get_todo_lists
      @todo_lists = TodoList.all
    end
  end
end