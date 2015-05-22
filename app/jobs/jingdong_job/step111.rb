module JingdongJob
  class Step111
    # 检查广交所是否上传文件至 FTP
    def run(step, args)
      fa = FileAgent.new(:guangjiaosuo)
      fa.download(:dir, args)

      if fa.files.count == 0
        {
          status: 'failed',
          message: "未检查到文件"
        }
      else
        fa.files.each {|pa| step.add_file(pa) }

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
    end
  end
end
