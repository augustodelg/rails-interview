module Api
  class TodoListItemsController < ApiController
    # POST /api/todolist/:todo_list_id/items
    def create
      service = TodoListItems::CreateService.call(
        todo_list_id: params[:todo_list_id], 
        params: todo_list_item_params
      )
      
      if service.success?
        @todo_list_item = service.result
        respond_to :json
      else
        render json: { errors: service.errors[:messages] }, status: service.errors[:status]
      end
    end

    # PUT /api/todolist/:todo_list_id/items/:id
    def update
      service = TodoListItems::UpdateService.call(
        todo_list_id: params[:todo_list_id], 
        todo_list_item_id: params[:id], 
        params: todo_list_item_params
      )

      if service.success?
        @todo_list_item = service.result
        respond_to :json
      else
        render json: { errors: service.errors[:messages] }, status: service.errors[:status]
      end
    end

    # DELETE /api/todolist/:todo_list_id/items/:id
    def destroy
      service = TodoListItems::DestroyService.call(
        todo_list_id: params[:todo_list_id], 
        todo_list_item_id: params[:id]
      )

      if service.success?
        @todo_list_item = service.result
        respond_to :json
      else
        render json: { errors: service.errors[:messages] }, status: service.errors[:status]
      end
    end

    # PUT /api/todolist/:todo_list_id/items/:id/complete
    def complete
      service = TodoListItems::CompleteService.call(
        todo_list_id: params[:todo_list_id], 
        todo_list_item_id: params[:id]
      )

      if service.success?
        @todo_list_item = service.result
        respond_to :json
      else
        render json: { errors: service.errors[:messages] }, status: service.errors[:status]
      end
    end

    private

    def todo_list_item_params
      params.require(:todo_list_item).permit(:description, :is_done)
    end
  end
end
