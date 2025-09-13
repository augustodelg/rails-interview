class TodoListsController < ApplicationController
  before_action :set_todo_list, only: [:show, :edit, :update, :destroy, :complete_all_items]
  
  # GET /todolists
  def index
    @todo_lists = TodoList.recent.includes(:todo_list_items)
    @todo_list = TodoList.new

    respond_to do |format|
      format.html
    end
  end

  # GET /todolists/:id
  def show
    @todo_list_item = @todo_list.todo_list_items.build
  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new
  end

  # GET /todolists/:id/edit
  def edit
  end

  # PATCH/PUT /todolists/:id
  def update
    if @todo_list.update(todo_list_params)
      redirect_to @todo_list, notice: 'Todo list was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    respond_to do |format|
      if @todo_list.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.prepend("todo_lists", partial: "todo_list", locals: { todo_list: @todo_list }),
            turbo_stream.replace("new_todo_list_form", partial: "form", locals: { todo_list: TodoList.new })
          ]
        }
        format.html { redirect_to @todo_list, notice: 'Todo list was successfully created.' }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("new_todo_list_form", partial: "form", locals: { todo_list: @todo_list })
        }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todolists/:id
  def destroy
    @todo_list.destroy

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.remove(@todo_list)
      }
      format.html { redirect_to todo_lists_url, notice: 'Todo list was successfully deleted.' }
    end
  end

  # PATCH /todolists/:id/complete_all_items
  def complete_all_items
    service = TodoLists::CompleteAllService.call(todo_list_id: @todo_list.id)
    
    if service.success?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @todo_list, notice: 'All items completed!' }
      end
    else
      redirect_to @todo_list, alert: 'Failed to complete all items'
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end