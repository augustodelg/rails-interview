module TodoLists
  class CompleteAllService < ApplicationService
    def initialize(todo_list_id:)
      super()
      @todo_list_id = todo_list_id
      @todo_list = nil
      @job = nil
    end

    def call
      begin
        find_todo_list
        validate_todo_list_exists
        
        enqueue_complete_all_job
        
        set_result({
          job_id: @job.job_id,
          todo_list_id: @todo_list_id,
          message: "Complete all items job queued successfully"
        })
        
      rescue ActiveRecord::RecordNotFound
        add_error('Todo list not found')
        set_error_status(:not_found)
      rescue StandardError => e
        add_error("Error queueing complete all job: #{e.message}")
      ensure
        return self
      end
    end

    private

    def find_todo_list
      @todo_list = TodoList.find(@todo_list_id)
    end

    def validate_todo_list_exists
      return if @todo_list
      
      add_error('Todo list not found')
      set_error_status(:not_found)
    end

    def enqueue_complete_all_job
      @job = CompleteAllItemsJob.perform_later(todo_list: @todo_list)
      Rails.logger.info "Enqueued CompleteAllItemsJob with job_id: #{@job.job_id} for TodoList ##{@todo_list_id}"
    end
  end
end