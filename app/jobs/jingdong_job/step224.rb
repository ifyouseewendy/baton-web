module JingdongJob
  class Step224
    # 发送，并等待确认
    def run(step, args)
      begin
        files = [
          Pathname(step.stage.tasks[1].files.first.file.current_path),  # 产品销售表
          Pathname(step.stage.tasks[1].files.last.file.current_path)    # 客户明细销售表
        ]
        files.each{|pa| check_existence_of!(pa)}

        platform = step.bourse
        fa = FileAgent.new(platform, env: args[:env])
        server_files = files.map{|pa| fa.upload(:file, file: pa.to_s, organization: platform)}

        {
          status: :succeed,
          type:   :message_list,
          stat:   server_files.map{|sf| "已上传至SFTP #{sf}"}
        }
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
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
