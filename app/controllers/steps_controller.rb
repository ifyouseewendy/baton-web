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

    def html_format(result)
      ret = {status: result[:status]}

      if result[:status] == :succeed
        data = result[:stat]
        if result[:type] == :file_list
          ret[:html] = \
            view_context.content_tag(
              :ul,
              -> {
                data.reduce('') do |str, ar|
                  str << \
                    view_context.content_tag(:li) do
                      view_context.link_to(ar[0], ar[1])
                    end
                end
              }.call,
              nil,
              false
            )
        else
        end
      else
        ret[:html] = view_context.content_tag(:p, result[:message])
      end

      ret
    end

end
