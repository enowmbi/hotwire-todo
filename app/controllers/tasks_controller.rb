class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.order("created_at desc")
  end

  # GET /tasks/1 or /tasks/1.json
  def show; end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(@task, partial: "tasks/form", locals:{ task: @task })
      end
    end
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('create_task_form', partial:"tasks/form", locals: { task: Task.new }),
            turbo_stream.prepend("tasks", partial: "tasks/task", locals: { task: @task }),
            turbo_stream.update("task_counter", html: Task.count),
            turbo_stream.update("notice", Constant::TASK_CREATED_MESSAGE)
          ]
        end
        format.html { redirect_to task_url(@task), notice: Constant::TASK_CREATED_MESSAGE }
        format.json { render :show, status: :created, location: @task }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('create_task_form', partial:"tasks/form", locals: { task: @task }),
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.turbo_stream do
          render turbo_stream: [ 
            turbo_stream.update(@task, partial: "tasks/task", locals: { task: @task }),
            turbo_stream.update("notice", Constant::TASK_UPDATED_MESSAGE)
          ]
        end
        format.html { redirect_to task_url(@task), notice: Constant::TASK_UPDATED_MESSAGE }
        format.json { render :show, status: :ok, location: @task }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(@task, partial: "tasks/form", locals: { task: @task })
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@task),
          turbo_stream.update("task_counter", html: Task.count),
          turbo_stream.update("notice", Constant::TASK_DESTROYED_MESSAGE)
        ]
      end
      format.html { redirect_to tasks_url, notice: Constant::TASK_DESTROYED_MESSAGE }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:title, :status)
  end
end
