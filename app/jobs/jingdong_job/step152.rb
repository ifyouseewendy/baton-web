module JingdongJob
  class Step152
    # 生成《产品合同文件》
    def run(step, args)
      begin
        file = Pathname(step.stage.tasks[2].files.first.file.current_path)
        check_existence_of!(file)

        new_name = "#{step.bourse}_产品合同文件_#{Date.today.to_s.gsub('-','')}.zip"
        target = file.dirname.join(new_name)

        FileUtils.cp file, target

        step.add_file(target.to_s, step.bourse, override: true)

        {
          status: :succeed,
          type: :file_list,
          stat: step.file_names.zip(step.file_urls)
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
