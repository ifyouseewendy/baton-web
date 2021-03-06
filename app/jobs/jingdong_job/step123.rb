require 'roo'
require 'roo-xls'

module JingdongJob
  class Step123
    # 生成京东指定格式 txt
    def run(step, args)
      begin
        @file = step.task.files.first.try(:file)
        @pa = Pathname.new @file.try(:current_path)

        output = @pa.dirname.join( @pa.basename(@pa.extname) ).to_s.chomp('/') + ".txt"

        File.open(output, 'w:GBK:UTF-8') do |wf|
          xlsx = Roo::Spreadsheet.open(@pa.to_s)

          sheet = xlsx.sheet(0)

          wf.puts sheet.row(1).reject(&:nil?).join("|")

          (2..sheet.last_row).each do |i|
            wf.puts sheet.row(i).map(&:to_s).map(&:strip).join("|")
          end
        end

        step.add_file(output, step.platform, override: true)

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

  end
end
