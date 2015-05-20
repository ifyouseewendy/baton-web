module JingdongJob
  class Step111
    # 检查广交所是否上传文件至 FTP
    def run(args)
      fa = FileAgent.new(:guangjiaosuo)
      fa.download(:dir, args)

      names, links = fa.names, fa.links

      if fa.files.count == 3
        {
          status: :succeed,
          type: :file_list,
          stat: names.zip(links)
        }
      else
        {
          status: 'failed',
          message: "No files"
        }
      end
    end
  end
end
