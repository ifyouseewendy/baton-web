module JingdongJob
  class Step211
    # 获取京东上传的《交易确认文件》
    def run(step, args)
      platform = :jingdong
      begin
        fa = FileAgent.new(platform)
        fa.download(:dir, args)

        if fa.files.count == 0
          {
            status: :failed,
            message: "未检查到文件"
          }
        else
          pa = fa.files.first

          if pa.extname == '.zip'
            Dir.chdir(pa.dirname)
            `7z e -y #{pa.basename}`
            Dir.chdir(Rails.root)

            pa = Pathname pa.to_s.sub('.zip', '.txt')
          end

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
          {
            status: :failed,
            message: e.message
          }
      end
    end
  end
end
