class StepsController < ApplicationController
  before_action :set_step, only: [:run]

  def run
    args = stage_params.merge({
      direction: :upload,
      date: '20150428'
    })
    @step.run(args)

    render json: html_format(@step.result)
  end

  private

    def set_step
      @step = Step.find(params[:id])
    end

    def stage_params
      params.permit(:project_id, :stage_id, :task_id, :id, :stub)
    end
end
