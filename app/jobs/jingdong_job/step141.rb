module JingdongJob
  class Step141
    # 发送给京东，等待确认
    def run(step, args)
      begin
        files = [
          Pathname(step.stage.tasks[1].files.first.file.current_path),  # 产品发布文件
          Pathname(step.stage.tasks[2].files.first.file.current_path)   # 产品合同文件
        ]
        files.each{|pa| check_existence_of!(pa)}

        platform = step.platform
        fa = FileAgent.new(platform)
        server_files = files.map{|pa| fa.upload(:file, file: pa.to_s, organization: platform)}

        {
          status: :succeed,
          type:   :message_list,
          stat:   server_files.map{|sf| "已上传至SFTP #{sf}"}
        }
      rescue => e
        {
          status: :failed,
          message: e.message
        }
      end
    end

    private

      def check_existence_of!(pa)
        raise "文件不存在 - #{pa}" unless pa.exist?
      end

  end
end
