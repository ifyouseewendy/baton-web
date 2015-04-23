require_relative 'kaitong_cli'
require 'csv'

class KaitongCli < Thor
  MAX_CODE_CAPACITY = 200

  desc 'daily_order_check', '处理天级客户销售明细'
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb daily_order_check --platform=xiaojin --project=alpha
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/jobs/resources/xiaojin/upload/20150320/xiaojin_天级客户明细销售表_20150320.csv
  LONGDESC
  option :from,       required: true
  option :platform,   required: true
  option :project,    required: true
  def daily_order_check
    load_rails

    DailyOrder.new(options[:platform], options[:project]).check(options[:from])
  end

  desc 'convert', '将资产单元编号映射成产品代码'
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb convert --code=K00001 --column=2
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/xiaojin/客户销售明细表.csv
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

        before_code = column > 0 ? row[0..(column-1)] : []
        after_code  = row[(column+1)..-1]
        of.puts (before_code + [code.to_s] + after_code).join(',')
        record_relation(row[column], code)

        if pos == MAX_CODE_CAPACITY
          pos = 0
          code.next!
        end
      end
    end

    puts ">> Generate file: #{output}"
    puts "    Code range: #{options[:code]} - #{code}"
  end

  desc 'generate_gjs_details', "生成广交所需要的《客户明细销售表》"
  long_desc <<-LONGDESC
    Parameters:

      from      - 为 convert 任务生成的文件地址
      platform  - 请填写中文名称
    Examples:

      ruby lib/tasks/xiaojin.rb generate_gjs_details --platform='小金理财'
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/xiaojin/客户销售明细表.csv
  LONGDESC
  option :from,     required: true
  option :platform, required: true
  def generate_gjs_details
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    out_filename = File.basename(options[:from]).split('.')[0]
    output = File.join(File.expand_path("../../../tmp", __FILE__), "#{out_filename}.detail.csv")

    platform = options[:platform]

    File.open(output, 'w') do |wf|

      wf.puts "客户姓名,客户全称,机构标志,证件类别,证件编号,证件地址,性别,电话,邮政编码,联系地址,传真,股权代码,股权数量,股权性质,上市日期,持仓均价,手机,风险级别,股权代码,营业部"

      File.open(options[:from], 'r') do |rf|
        rf.each_with_index do |line, i|
          next if line.empty?

          columns = line.split(',')
          code = columns[2]
          wf.puts [columns[4], nil, 0, 0, columns[5], platform, columns[7], columns[6], '100000', platform, nil, columns[2], columns[3].to_i, nil, nil, 1, columns[6], 1, code, '2002' ].join(',')
        end
      end
    end

    puts ">> Generate file: #{output}"

  end

  private

    def record_relation(stat, code)
      prd = Product.find_or_create_by(code: code.to_s)
      prd.property_serial << stat
      prd.save!
    end
end

KaitongCli.start(ARGV)
