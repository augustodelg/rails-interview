module Api
  class TodoListsController < ApiController
    # GET /api/todolists
    def index
      service = TodoLists::GetAllServices.call
      
      if service.success?
        @todo_lists = service.result
        respond_to :json
      else
        render json: { errors: service.errors[:messages] }, status: service.errors[:status]
      end
    end

    # POST /api/todolists/:id/complete_all_items
    def complete_all_items
      service = TodoLists::CompleteAllService.call(todo_list_id: params[:id])
      
      if service.success?
        render json: { 
          message: "Complete all job queued successfully", 
          job_id: service.result[:job_id],
          todo_list_id: params[:id]
        }, status: :accepted
      else
        render json: { errors: service.errors[:messages] }, status: service.errors[:status]
      end
    end
  end
end
