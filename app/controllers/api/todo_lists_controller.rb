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
  end
end
