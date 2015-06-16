module JingdongJob
  class Step212
    # 检验
    def run(step, args)
      begin
        @file = step.task.files.first.try(:file)

        if args[:env] == :online
          @pa = Pathname.new @file.try(:current_path)
        else
          @pa = Rails.root.join('samples').join('jingdong').join('交易确认文件.txt')
        end

        total_rows, total_amount, total_fee, rows, amount, fee = [0]*6

        product_summary = Hash.new(0)

        File.open(@pa, 'r:GBK') do |rf|
          rf.each_with_index do |line, i|
            next if i == 1
            next if line.empty?

            columns = line.split("|")

            if i == 0
              total_rows    = columns[1].split(":").last.to_i
              total_amount  = columns[2].split(":").last.to_i
              total_fee     = columns[3].split(":").last.to_i
            else
              rows    += 1
              amount  += columns[7].to_i
              fee     += columns[10].to_i

              code    = columns[1][-6..-1]
              product_summary[code] += columns[7].to_i
            end
          end
        end

        check_equality!("总笔数",      total_rows,   rows)
        check_equality!("总金额",      total_amount, amount)
        check_equality!("手续费总额",  total_fee,    fee)
        product_summary.sort_by{|k,v| k}.map{|k,v| puts "#{k}: #{v}"}

        {
          status: :succeed
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

      def check_equality!(name, a, b)
        raise "--> <#{name}> Don't Match: #{a} - #{b}" unless a == b
      end

  end
end
