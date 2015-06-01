module JingdongJob
  class Step151
    # 填写《产品销售计划表》，并上传、校验
    def run(step, args)
      begin
        source      = Pathname(args[:file].tempfile)
        check_ext_type!(source)

        target_name = ["#{step.bourse}_产品销售计划表_#{Date.today.to_s.gsub('-','')}", source.extname].join # Auto correct file, or it should be args[:file].original_filename
        target_path = Pathname(source.dirname).join(target_name)
        FileUtils.mv(source, target_path)

        step.add_file(target_path, step.bourse, override: true)

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

    private

      def check_ext_type!(pa)
        raise "文件类型不是 csv" unless '.csv' == pa.extname.to_s
      end

  end
end
