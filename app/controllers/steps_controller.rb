class StepsController < ApplicationController
  before_action :set_step, only: [:run, :send_file]

  def run
    @step.run(stage_params)

    render json: ApplicationController.helpers.html_format(@step.result)
  end

  def send_file
    content = @step.file.read
    if stale?(etag: content, last_modified: @step.updated_at.utc, public: true)
      send_data content, type: @step.file.content_type, disposition: "inline"
      expires_in 0, public: true
    end
  end

  private

    def set_step
      @step = Step.find(params[:id])
    end

    def stage_params
      params.permit(:id, :file, :direction, :date, :product_start_code, :product_count, :product_index_length)
    end

end
