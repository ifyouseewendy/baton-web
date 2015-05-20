module JingdongJob
  class Step111
    # 检查广交所是否上传文件至 FTP
    def run(args)
      fa = FileAgent.new(:guangjiaosuo)
      fa.download(:dir, args)

      names, links = fa.names, fa.links

      {file_list: names.zip(links)}
    end
  end
end
