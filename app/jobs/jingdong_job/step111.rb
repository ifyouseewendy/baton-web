module JingdongJob
  class Step111
    # 检查广交所是否上传文件至 FTP
    def run(args)
      fa = FileAgent.new(:guangjiaosuo)
      fa.download(:dir, args)

      names, links = fa.names, fa.links

      if fa.files.count == 0
        {
          status: 'failed',
          message: "未检查到文件"
        }
      else
        {
          status: :succeed,
          type: :file_list,
          date: args[:date],
          stat: names.zip(links)
        }
      end
    end
  end
end
