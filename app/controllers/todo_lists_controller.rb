class TodoListsController < ApplicationController
  before_action :set_todo_list, only: [:show, :edit, :update, :destroy, :complete_all]

  # GET /todolists
  def index
    @todo_lists = TodoList.includes(:todo_list_items).all
    @todo_list = TodoList.new # For new form
  end

  # GET /todolists/:id  
  def show
  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      respond_to do |format|
        format.turbo_stream { 
          render turbo_stream: turbo_stream.prepend("todo_lists", 
            partial: "todo_lists/todo_list", 
            locals: { todo_list: @todo_list }
          )
        }
        format.html { redirect_to todolists_path, notice: 'Todo list created successfully.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("new_todo_list_form", 
            partial: "todo_lists/form", 
            locals: { todo_list: @todo_list }
          )
        }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # POST /todolists/:id/complete_all
  def complete_all
    service = TodoLists::CompleteAllService.call(todo_list_id: @todo_list.id)
    
    respond_to do |format|
      if service.success?
        format.turbo_stream { 
          render turbo_stream: turbo_stream.append("notifications", 
            partial: "shared/notification", 
            locals: { message: "Complete all job queued!", type: "info" }
          )
        }
        format.html { redirect_to todolists_path, notice: 'Complete all job queued!' }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.append("notifications", 
            partial: "shared/notification", 
            locals: { message: service.errors[:messages].join(', '), type: "error" }
          )
        }
        format.html { redirect_to todolists_path, alert: service.errors[:messages].join(', ') }
      end
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
