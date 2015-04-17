require 'roo'
require 'roo-xls'
require 'mongoid'
require 'tempfile'
require_relative 'kaitong_cli'
require File.expand_path('../../models/rate_calculator', __FILE__)

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

    File.open(output, 'w:GBK:UTF-8') do |wf|
      sheet = xlsx.sheet(0)

      wf.puts sheet.row(1).reject(&:nil?).join("|")

      (2..sheet.last_row).each do |i|
        wf.puts sheet.row(i).join("|")
      end
    end

    # convert_file_encoding!(output)

    puts ">> Generate file: #{output}"
  end

  desc 'invest_check', "校验交易确认文件"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/jingdong.rb invest_check --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/jingdong/kaitong_invest_20150414.txt
  LONGDESC
  option :from,   required: true
  def invest_check
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    total_rows, total_amount, total_fee, rows, amount, fee = [0]*6

    product_summary = Hash.new(0)

    File.open(options[:from], 'r:GBK') do |rf|
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

    check_equality("总笔数",      total_rows,   rows)
    check_equality("总金额",      total_amount, amount)
    check_equality("手续费总额",  total_fee,    fee)
    puts "-"*20
    product_summary.sort_by{|k,v| k}.map{|k,v| puts "#{k}: #{v}"}
  end

  desc 'generate_refund', "生成交易还款（试算）文件"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/jingdong.rb generate_refund --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/jingdong/kaitong_invest_20150411.txt --rate=0.0783
  LONGDESC
  option :from, required: true
  option :rate, type: :numeric, required: true
  option :test, type: :boolean, default: true
  option :kaitong_order
  option :return_reason
  option :bank_order
  def generate_refund
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    rate              = options[:rate]
    kaitong_order     = options[:kaitong_order] || BSON::ObjectId.new.to_s
    return_reason     = options[:return_reason]
    return_timestamp  = Time.now.to_s(:db).to_s.gsub('-', '')
    bank_order        = options[:bank_order]

    total_rows, total_amount, total_fee = [0]*3

    orders = []
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
          jingdong_order    = columns[0].strip.to_s
          product_code      = columns[1].strip.to_s
          jingdong_user_id  = columns[2].strip.to_s
          return_type       = 1
          return_base       = columns[7].to_i
          return_interest   = RateCalculator.new(return_base, rate).run
          return_amount     = return_base + return_interest

          rr = RefundRecord.new(
            kaitong_order, jingdong_order, product_code,
            jingdong_user_id, return_type, return_amount,
            return_base, return_interest, return_timestamp,
            return_reason, bank_order
          )

          orders << rr
        end
      end
    end

    parts = ["kaitong", "refund"]
    parts << "test" if options[:test]
    parts << Date.today.to_s.gsub('-', '')
    output = File.join(File.expand_path("../../../tmp", __FILE__), "#{parts.join('_')}.txt")

    File.open(output, 'w') do |wf|
      wf.puts ["version:1", "总笔数:#{orders.count}", "总金额:#{orders.map(&:return_amount).sum}"].join("|")
      wf.puts RefundRecord::VOCABULARY.values.join("|")
      orders.each{|order| wf.puts order.values.join("|")}
    end

    puts ">> Generate file: #{output}"
  end

  desc 'generate_gjs_details', "生成广交所需要的《客户明细销售表》"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/jingdong.rb generate_gjs_details --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/jingdong/kaitong_invest_20150414.txt
  LONGDESC
  option :from, required: true
  def generate_gjs_details
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    out_filename = File.basename(options[:from]).split('.')[0]
    output = File.join(File.expand_path("../../../tmp", __FILE__), "#{out_filename}.detail.csv")

    File.open(output, 'w:GBK') do |wf|

      wf.puts "客户姓名,客户全称,机构标志,证件类别,证件编号,证件地址,性别,电话,邮政编码,联系地址,传真,股权代码,股权数量,股权性质,上市日期,持仓均价,手机,风险级别,股权代码,营业部"

      File.open(options[:from], 'r:GBK') do |rf|
        rf.each_with_index do |line, i|
          next if i <= 1
          next if line.empty?

          columns = line.split("|")

          platform = '京东平台'
          code = columns[1][-6..-1]
          wf.puts [columns[3], nil, 0, 0, columns[4], platform, nil, platform, platform, platform, nil, code, columns[7].to_i, nil, nil, 1, columns[5], 1, code, nil].map(&:to_s).map{|str| str.encode(Encoding::GBK)}.join(",")
        end
      end
    end

    puts ">> Generate file: #{output}"

  end

  private

    def check_equality(name, a, b)
      if a == b
        puts "--> <#{name}> Equals: #{a}"
      else
        puts "--> <#{name}> Don't Match: #{a} - #{b}"
      end
    end

    def convert_file_encoding!(file, from="UTF-8", to="GBK")
      content = File.read(file)
      File.open(file, "w:#{to}:#{from}"){|wf| wf.write content }
    end

end

RefundRecord = \

  Struct.new(:kaitong_order, :jingdong_order, :product_code,
             :jingdong_user_id, :return_type, :return_amount,
             :return_base, :return_interest, :return_timestamp,
             :return_reason, :bank_order) do

    VOCABULARY = {
      kaitong_order:      '合作机构订单号',
      jingdong_order:     '京东金融订单号',
      product_code:       '合作机构产品代码',
      jingdong_user_id:   '京东金融用户ID',
      return_type:        '还款类型',
      return_amount:      '还款总金额',
      return_base:        '还款本金',
      return_interest:    '还款利息',
      return_timestamp:   '交易确认时间',
      return_reason:      '退款原因',
      bank_order:         '转账流水号'
    }

    def values
      [
        kaitong_order, jingdong_order, product_code,
        jingdong_user_id, return_type, return_amount,
        return_base, return_interest, return_timestamp,
        return_reason, bank_order
      ]
    end

  end


KaitongCli.start(ARGV)
