module JingdongJob
  class Step153
    # 发送给交易所，等待确认
    def run(step, args)
      begin
        files = step.task.files.map{|f| Pathname(f.file.current_path) }
        files.each{|pa| check_existence_of!(pa)}

        platform = step.bourse
        fa = FileAgent.new(platform)
        server_files = files.map{|pa| fa.upload(:file, file: pa.to_s, platform: platform)}

        {
          status: :succeed,
          type:   :message_list,
          stat:   server_files.map{|sf| "已将文件上传至SFTP #{sf}"}
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
