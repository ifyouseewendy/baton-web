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
end

KaitongCli.start(ARGV)
