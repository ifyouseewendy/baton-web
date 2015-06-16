module JingdongJob
  class Step121
    # 上传《产品发布文件》
    def run(step, args)
      begin
        source      = Pathname(args[:file].tempfile)
        target_name = ["#{get_bourse(step)}_product_apply_#{step.project.get_serial}", source.extname].join # Auto correct file, or it should be args[:file].original_filename
        target_path = Pathname(source.dirname).join(target_name)
        FileUtils.mv(source, target_path)

        step.add_file(target_path, step.platform, override: true)

        {
          status: :succeed,
          type: :file_list,
          stat: step.file_names.zip(step.file_urls)
        }
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
        {
          status: :failed,
          message: e.message
        }
      end
    end

    private

      def get_bourse(step)
        bourse = step.project.bourse
        bourse = :kaitong if bourse == :guangjiaosuo # Incompatible name for Jingdong
        bourse
      end
  end
end
