module JingdongJob
  class Step131
    # 批量生成产品合同
    def run(step, args)
      template = step.stage.files.detect{|af| Pathname(af.file.current_path).extname == '.html' }

      start_code, count, index = args.values_at(
        :product_start_code,
        :product_count,
        :product_index
      )
      binding.pry

      begin

        {
          status: :succeed
        }
      rescue => e
        {
          status: :failed,
          message: e.message
        }
      end
    end

  end
end
