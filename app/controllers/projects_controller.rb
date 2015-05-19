class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    respond_to do |format|
      format.html { redirect_to project_stage_path(@project, @project.current_stage) }
      format.json do
        render json: {
          name:           @project.name,
          env:            @project.zh_env,
          platform:       @project.platform,
          category:       @project.category,
          category_index: @project.category_index
        }
      end
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    begin
      project = Project.build_by(project_params[:recipe])
      project.update_attributes!(project_params)

      flash[:notice] = "项目 #{project.name} 创建成功"
    rescue => e
      project.delete

      messages = e.message.split("\n")
      i = messages.index('Summary:')
      j = messages.index('Resolution:')
      flash[:alert] = messages[i+1...j].join("\n")
    end

    respond_to do |format|
      format.html { redirect_to projects_path }
    end
  end

  # PATCH/PUT /projects/1
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to projects_path, notice: "项目 #{@project.name} 更新成功" }
      else
        format.html { redirect_to projects_path, alert: @project.errors.full_messages.join("\n") }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    name = @project.name
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: "项目 #{name} 删除成功" }
      format.json { head :no_content }
    end
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :category, :env, :recipe, :platform)
    end
end
