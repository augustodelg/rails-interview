module Api
  class TodoListItemController < ApiController
    # POST /api/todolist/:todo_list_id/items
    def create
      service = TodoListItems::CreateService.call(params[:todo_list_id], todo_list_item_params)

      if service.success?
        @todo_list_item = service.result
        render json:
      else
        render json: { errors: service.errors }, status: :unprocessable_entity
      end
    end

    # PUT /api/todolist/:todo_list_id/items/:id
    def update
    end

    # DELETE /api/todolist/:todo_list_id/items/:id
    def destroy
    end

    # PUT /api/todolist/:todo_list_id/items/:id/complete
    def complete
    end

    private

    def todo_list_item_params
      params.require(:todo_list_item).permit(:description, :is_done)
    end
  end
end
