module JingdongJob
  class Step222
    # 检验文件内容与编码
    def run(step, args)
      begin
        @file = step.task.files.first.try(:file)
        @pa = Pathname.new @file.try(:current_path)
        check_existence!
        check_ext_type!

        convert_file_encoding!(@pa) if 'UTF-8' == detect_file_encoding(@pa)
        {
          status: :succeed
        }
      rescue => e
        {
          status: :failed,
          message: e.message
        }
      end
    end

    private

      def check_existence!
        raise "文件不存在 - #{@pa}" unless @pa.exist?
      end

      def check_ext_type!
        raise "文件类型不是 csv - #{@pa.basename}" unless %w(.csv).include?(@pa.extname)
      end

      def convert_file_encoding!(file, from="UTF-8", to="GBK")
        content = File.read(file, encoding:from)
        File.open(file, "w:#{to}:#{from}"){|wf| wf.write content }
      end

      def detect_file_encoding(file)
        contents = File.read(file)
        detection = CharlockHolmes::EncodingDetector.detect(contents)
        detection[:encoding] rescue nil
      end

  end
end
