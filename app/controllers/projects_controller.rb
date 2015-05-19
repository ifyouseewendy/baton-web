class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  skip_before_filter :verify_authenticity_token, :only => [:create]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    redirect_to project_stage_path(@project, @project.current_stage)
    # render: @project.current_stage
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
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
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :category, :env, :recipe)
    end

end
