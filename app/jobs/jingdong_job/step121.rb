module JingdongJob
  class Step121
    # 上传《产品发布文件》
    def run(step, args)
      begin
        source            = Pathname(args[:file].tempfile)
        original_filename = args[:file].original_filename
        target_path       = Pathname(source.dirname).join(original_filename)
        FileUtils.mv( source, target_path)

        step.add_file(target_path, step.recipe, override: true)

        {
          status: :succeed,
          type: :file_list,
          stat: step.file_names.zip(step.file_urls)
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
