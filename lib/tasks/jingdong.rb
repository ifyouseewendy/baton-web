require_relative 'kaitong_cli'
require 'roo'
require 'roo-xls'

class KaitongCli < Thor
  desc 'convert', '产品发布文件.xls(x) -> 产品发布文件.txt'
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/jingdong.rb convert --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/jingdong/kaitong_product_apply_20150411.xls
      ruby lib/tasks/jingdong.rb convert --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/jingdong/kaitong_product_apply_20150411.xlsx
  LONGDESC
  option :from,   required: true
  def convert
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    xlsx = Roo::Spreadsheet.open(options[:from])

    out_filename = File.basename(options[:from]).split('.')[0]
    output = File.join(File.expand_path("../../../tmp", __FILE__), "#{out_filename}.txt")

    File.open(output, 'w') do |wf|
      sheet = xlsx.sheet(0)

      wf.puts sheet.row(1).reject(&:nil?).join("|")

      (2..sheet.last_row).each do |i|
        wf.puts sheet.row(i).join("|")
      end
    end

    puts ">> Generate file: #{output}"
  end

  desc 'invest_check', "校验交易确认文件"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/jingdong.rb invest_check --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/jingdong/kaitong_invest_20150411.txt
  LONGDESC
  option :from,   required: true
  def invest_check
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    total_rows, total_amount, total_fee, rows, amount, fee = [0]*6

    File.open(options[:from], 'r') do |rf|
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
        end
      end
    end

    check_equality("总笔数",      total_rows,   rows)
    check_equality("总金额",      total_amount, amount)
    check_equality("手续费总额",  total_fee,    fee)

  end

  private

    def check_equality(name, a, b)
      if a == b
        puts "--> <#{name}> Equals: #{a}"
      else
        puts "--> <#{name}> Don't Match: #{a} - #{b}"
      end
    end

end

KaitongCli.start(ARGV)
