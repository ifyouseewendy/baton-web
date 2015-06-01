module JingdongJob
  class Step111
    # 检查交易所是否上传文件至 FTP
    def run(step, args)
      bourse = step.bourse
      begin
        fa = FileAgent.new(bourse)
        fa.download(:dir, args)

        if fa.files.count == 0
          {
            status: :failed,
            message: "未检查到文件"
          }
        else
          step.clear_file!
          fa.files.each {|pa| step.add_file(pa, bourse) }

          names, links = fa.names, fa.links
          {
            status: :succeed,
            type: :file_list,
            query: {
              date: args[:date]
            },
            stat: names.zip(links)
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
