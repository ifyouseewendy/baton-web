require_relative 'kaitong_cli'
require 'csv'
require File.expand_path('../../models/rate_calculator', __FILE__)

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
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/xiaojin/xiaojin_客户明细销售表_20150423.csv
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
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/tmp/xiaojin_客户明细销售表_20150423.detail.csv
  LONGDESC
  option :from,     required: true
  option :platform, required: true
  def generate_gjs_details
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    convert_file_encoding!(options[:from], 'GBK', 'UTF-8')

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

    convert_file_encoding!(output)

    puts ">> Generate file: #{output}"

  end

  desc 'generate_gjs_overview', "生成广交所需要的《产品销售表》"
  long_desc <<-LONGDESC
    Parameters:

      from          - 为 convert 任务生成的文件地址
      from_overview - 小金传送来的《产品销售表》
    Examples:

      ruby lib/tasks/xiaojin.rb generate_gjs_overview
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/tmp/tuniu_客户明细销售表_20150423.out.csv
        --from_overview=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/xiaojin/xiaojin_产品销售表_20150423.csv
  LONGDESC
  option :from,             required: true
  option :from_overview,    required: true
  def generate_gjs_overview
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])
    raise "Invalid <from_overview> file position: #{options[:from_overview]}" unless File.exist?(options[:from_overview])

    code_amount = Hash.new(0)
    File.open(options[:from], 'r') do |rf|
      rf.each_line do |line|
        next if line.empty?
        columns = line.split(',')
        code_amount[columns[0]] += columns[3].to_f
      end
    end

    out_filename = File.basename(options[:from_overview]).split('.')[0]
    output = File.join(File.expand_path("../../../tmp", __FILE__), "#{out_filename}.overview.csv")

    File.open(output, 'w:GBK') do |wf|

      wf.puts "产品代码,交易板块,债券简称,债券全称,总发行量,发行价,持仓户数上限,票面利率,年付息次数,付息安排,发行模式,发行日期,上市日期,到期日期,起息日期,兑息日期,交易状态,委托数量下限,委托数量上限,交易基数"

      File.open(options[:from_overview], 'r:GBK') do |rf|
        rf.each_with_index do |line, i|
          next if line.empty?

          columns = line.split(',')

          raise 'No match amount from detail and overview' unless code_amount.values.reduce(:+) == columns[3].to_i

          code_amount.each do |code, amount|
            wf.puts [code, '98', columns[1], columns[2], amount, '1', '200', columns[7], '1', '', '1', columns[11], columns[12], columns[13], columns[14], columns[15], '3', columns[17], columns[18], columns[19]].map(&:to_s).map{|str| str.encode(Encoding::GBK)}.join(',')
          end
        end
      end
    end

    puts ">> Generate file: #{output}"

  end

  desc 'generate_refund', "生成交易试算文件"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb generate_refund --rate=0.0783
        --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/xiaojin/xiaojin_客户明细销售表_20150423.csv
  LONGDESC
  option :from, required: true
  option :rate, type: :numeric, required: true
  def generate_refund
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    rate              = options[:rate]

    out_filename = File.basename(options[:from], '.csv')
    output = File.join(File.expand_path("../../../tmp", __FILE__), "#{out_filename}.refund.csv")

    File.open(output, 'w') do |wf|
      stats = []
      total_rows, total_amount = [0]*2

      CSV.foreach(options[:from]) do |row|
        next if row[0].empty?

        total_rows += 1

        return_base       = row[3].to_i
        return_interest   = RateCalculator.new(return_base, rate).run.to_f
        return_amount     = return_base + return_interest
        stats << [
          row[2], row[4], row[5], return_base, rate, return_interest, return_amount
        ]

        total_amount += return_amount
      end

      stats.unshift [total_rows, total_amount]

      stats.each{|stat| wf.puts stat.join(',')}
    end

    puts ">> Generate file: #{output}"
  end


  private

    def record_relation(stat, code)
      prd = Product.find_or_create_by(code: code.to_s)
      prd.property_serial << stat
      prd.save!
    end

    def convert_file_encoding!(file, from="UTF-8", to="GBK")
      content = File.read(file, encoding:from)
      File.open(file, "w:#{to}:#{from}"){|wf| wf.write content }
    end
end

KaitongCli.start(ARGV)
