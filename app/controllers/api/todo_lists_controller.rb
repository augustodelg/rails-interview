module Api
  class TodoListsController < ApiController
    # GET /api/todolists
    def index
      service = TodoLists::GetAllServices.call
      
      if service.success?
        @todo_lists = service.result
        respond_to :json
      else
        render json: { errors: service.errors }, status: :unprocessable_entity
      end
    end
  end
end
