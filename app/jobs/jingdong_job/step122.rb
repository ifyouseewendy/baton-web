module JingdongJob
  class Step122
    # 检验文件内容与编码
    def run(step, args)
      begin
        @file = step.task.files.first.try(:file)
        @pa = Pathname.new @file.try(:current_path)
        check_existence!
        check_ext_type!

        # Make this operation in step 121
        # auto_correct_name!

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
        raise "文件类型不是 xls(x) - #{@pa.basename}" unless %w(.xls .xlsx).include?(@pa.extname)
      end

      def auto_correct_name!
        name = ["kaitong_product_apply_#{Date.today.to_s.gsub('-','')}", @pa.extname].join
        unless name == @pa.basename.to_s
          @file.rename! name
        end
      end

  end
end
