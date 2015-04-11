require_relative 'kaitong_cli'
require 'csv'

class KaitongCli < Thor
  MAX_CODE_CAPACITY = 200

  desc 'convert', '将资产单元编号映射成产品代码'
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb convert --code=K00001 --column=2
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/客户销售明细表.csv
  LONGDESC
  option :from,   required: true
  option :column, type: :numeric, required: true
  option :code,   required: true
  def convert
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    load_rails

    column = options[:column]
    out_filename = File.basename(options[:from], '.csv')
    output = File.join(Rails.root, 'tmp', "#{out_filename}.out.csv")
    code = ProductCode.new(options[:code])
    File.open(output, 'w') do |of|
      pos = 0
      CSV.foreach(options[:from]) do |row|
        pos += 1

        next if row[0].blank?

        of.puts (row[0..(column-1)] + [code.to_s] + row[(column+1)..-1]).join(',')
        record_relation(row[column], code)

        if pos == MAX_CODE_CAPACITY
          pos = 0
          code.next!
        end
      end
    end

    puts "--> Generate file: #{output}"
    puts "    Code range: #{options[:code]} - #{code}"
  end

  private

    def record_relation(stat, code)
      prd = Product.find_or_create_by(code: code.to_s)
      prd.property_serial << stat
      prd.save!
    end
end

KaitongCli.start(ARGV)
