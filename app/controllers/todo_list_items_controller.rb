class TodoListItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_todo_list_item, only: [:toggle, :destroy]

  # GET /todolists/:todo_list_id/items/new
  def new
    @todo_list_item = @todo_list.todo_list_items.build
  end

  # POST /todolists/:todo_list_id/items
  def create
    service = TodoListItems::CreateService.call(
      todo_list_id: params[:todo_list_id],
      params: todo_list_item_params
    )

    if service.success?
      @todo_list_item = service.result
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_lists_path, notice: 'Item created!' }
      end
    else
      service.errors[:messages].each { |msg| @todo_list_item.errors.add(:base, msg) }
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /todolists/:todo_list_id/items/:id/toggle
  def toggle
    service = TodoListItems::ToggleService.call(
      todo_list_id: params[:todo_list_id],
      todo_list_item_id: params[:id]
    )

    if service.success?
      @todo_list_item = service.result
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_lists_path, notice: 'Item toggled!' }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to todo_lists_path, alert: 'Failed to toggle item' }
      end
    end
  end

  # DELETE /todolists/:todo_list_id/items/:id
  def destroy
    service = TodoListItems::DestroyService.call(
      todo_list_id: params[:todo_list_id],
      todo_list_item_id: params[:id]
    )

    if service.success?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_lists_path, notice: 'Item deleted!' }
      end
    else
      redirect_to todo_lists_path, alert: 'Failed to delete item'
    end
  end

  private
  
  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_todo_list_item
    @todo_list_item = @todo_list.todo_list_items.find(params[:id])
  end
  
  def todo_list_item_params
    params.require(:todo_list_item).permit(:description, :is_done)
  end
end