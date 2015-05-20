class StepsController < ApplicationController
  before_action :set_step, only: [:run]

  def run
    @step.run(stage_params)

    render json: ApplicationController.helpers.html_format(@step.result)
  end

  private

    def set_step
      @step = Step.find(params[:id])
    end

    def stage_params
      params.permit(:id, :direction, :date)
    end

end
