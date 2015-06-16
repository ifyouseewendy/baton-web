module JingdongJob
  class Step211
    # 获取京东上传的《交易确认文件》
    def run(step, args)
      platform = step.platform
      begin
        fa = FileAgent.new(platform, env: args[:env])
        fa.download(:dir, args)

        pa = fa.files.detect{|_f| _f.basename.to_s =~ /#{step.project.get_serial}.zip$/}
        if pa.nil?
          {
            status: :failed,
            message: "未检查到文件"
          }
        else
          Dir.chdir(pa.dirname)
          `7z e -y #{pa.basename}`
          Dir.chdir(Rails.root)

          pa = pa.dirname.entries.detect{|_pa| _pa.basename.to_s =~ /#{step.project.get_serial}.txt$/}.expand_path(pa.dirname)

          step.add_file(pa, platform, override: true)

          {
            status: :succeed,
            type: :file_list,
            query: {
              date: args[:date]
            },
            stat: step.file_names.zip(step.file_urls)
          }
        end
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
