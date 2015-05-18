class StepsController < ApplicationController
  before_action :set_step, only: [:run]

  def run
    sleep(3)

    begin
      @step.run(params)
      render json: { status: 'succeed' }
    rescue => e
      puts e.message
      puts e.backtrace
      render json: { status: 'failed', message: "Sorry dude, it's sucked" }
    end
  end

  private

    def set_step
      @step = Step.find(params[:id])
    end

    def stage_params
      params.permit(:project_id, :stage_id, :task_id, :id, :stub)
    end
end
