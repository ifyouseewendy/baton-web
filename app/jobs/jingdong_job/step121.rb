module JingdongJob
  class Step121
    # 上传《产品发布文件》
    def run(step, args)
      begin
        source      = Pathname(args[:file].tempfile)
        target_name = ["kaitong_product_apply_#{Date.today.to_s.gsub('-','')}", source.extname].join # Auto correct file, or it should be args[:file].original_filename
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

  end
end
