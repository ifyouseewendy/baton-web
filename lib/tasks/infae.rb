require_relative 'kaitong_cli'

class KaitongCli < Thor

  desc 'convert_invest_check', '京东新版《交易确认文件》 -> 辽金所需求的旧版《交易确认文件》'
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/infae.rb convert --from=/Users/wendi/Workspace/kaitong/baton-web/samples/jingdong/交易确认文件.txt
  LONGDESC
  option :from,   required: true
  def convert
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    out_filename = File.basename(options[:from]).split('.')[0]
    output = File.join(File.expand_path("../../../tmp", __FILE__), "#{out_filename}.txt")

    File.open(output, 'w:GBK') do |wf|
      headers = ['机构代码', '京东订单号', '投资人姓名', '身份证号', '手机号', '申购金额', '支付时间', '是否开过户', '产品代码', '是否完成风险评估', '风险评估得分']

      File.open(options[:from], 'r:GBK') do |rf|
        rf.each_with_index do |line, i|
          next if line.empty?

          if i == 0
            wf.puts line
          elsif i == 1
            wf.puts headers.join('|')
          else
            cols = line.split("|")
            content = ['infae', cols[0], cols[3], cols[4], cols[5], cols[7], cols[8], 0, cols[1], 1, nil]

            wf.puts content.map(&:to_s).map{|str| str.encode(Encoding::GBK)}.join('|')
          end

        end
      end
    end

    puts ">> Generate file: #{output}"
  end

end

KaitongCli.start(ARGV)
