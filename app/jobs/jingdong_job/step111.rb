module JingdongJob
  class Step111
    # 检查广交所是否上传文件至 FTP
    def run(args)
      project_id = args[:project_id]
      date = args[:date] || Date.today.to_s.gsub('-', '')
      date = '20150414'

      from_dir = "/home/jingdong/download/#{date}"

      to_dir = File.join(Rails.root, "public", "resources", project_id, "download")
      FileUtils.mkdir_p to_dir

      ::SftpProxy.download_dir(from_dir, to_dir)
    end
  end
end
