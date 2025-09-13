class TodoListItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_todo_list_item, only: [:show, :edit, :update, :destroy, :complete, :toggle]

  # GET /todolists/:todo_list_id/items/new
  def new
    @todo_list_item = @todo_list.todo_list_items.build
  end

  # POST /todolists/:todo_list_id/items
  def create
    service = TodoListItems::CreateService.call(
      todo_list_id: @todo_list.id,
      params: todo_list_item_params
    )

    if service.success?
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to todo_lists_path, notice: 'Item created!' }
      end
    else
      @todo_list_item = TodoListItem.new(todo_list_item_params.merge(todo_list: @todo_list))
      service.errors[:messages].each { |msg| @todo_list_item.errors.add(:base, msg) }
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todolists/:todo_list_id/items/:id
  def update
    service = TodoListItems::UpdateService.call(
      todo_list_id: @todo_list.id,
      todo_list_item_id: @todo_list_item.id,
      params: todo_list_item_params
    )

    if service.success?
      redirect_to todo_lists_path, notice: 'Item updated!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # PATCH /todolists/:todo_list_id/items/:id/toggle
  def toggle
    service = TodoListItems::UpdateService.call(
      todo_list_id: @todo_list.id,
      todo_list_item_id: @todo_list_item.id,
      params: { is_done: !@todo_list_item.is_done }
    )

    if service.success?
      redirect_to todo_lists_path
    else
      redirect_to todo_lists_path, alert: 'Failed to toggle item'
    end
  end

  # DELETE /todolists/:todo_list_id/items/:id
  def destroy
    service = TodoListItems::DestroyService.call(
      todo_list_id: @todo_list.id,
      todo_list_item_id: @todo_list_item.id
    )

    if service.success?
      redirect_to todo_lists_path, notice: 'Item deleted!'
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