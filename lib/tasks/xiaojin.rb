require_relative 'kaitong_cli'
require 'csv'
require File.expand_path('../../models/rate_calculator', __FILE__)

class KaitongCli < Thor
  desc 'generate_gjs_details', "生成广交所需要的《客户明细销售表》"
  long_desc <<-LONGDESC
    Parameters:

      from - 为记录"专业执行人"信息的文件地址，格式为 "姓名,身份证,手机号,性别,产品代码,购买金额,证件地址,联系地址,邮政编码"

    Examples:

      ruby lib/tasks/xiaojin.rb generate_gjs_details
        --from=/Users/wendi/Workspace/kaitong/baton-web/samples/xiaojin/专业执行人.csv
  LONGDESC
  option :from,     required: true
  def generate_gjs_details
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    today = Date.today.to_s.gsub('-','')
    out_filename = "guangjiaosuo_客户销售明细表_#{today}.csv"
    output = File.join(File.expand_path("../../../tmp", __FILE__), out_filename)

    headers = "客户姓名,客户全称,机构标志,证件类别,证件编号,证件地址,性别,电话,邮政编码,联系地址,传真,股权代码,股权数量,股权性质,上市日期,持仓均价,手机,风险级别,股权代码,营业部"
    business_code = '3002'

    File.open(output, 'w') do |wf|
      wf.puts headers.split(',').map{|str| str.encode(Encoding::GBK)}.join(",")

      File.open(options[:from], 'r') do |rf|
        rf.each_with_index do |line, i|
          next if line.empty?
          name, id, mobile, gender, product_code, amount, id_address, contact_address, post_code = line.strip.split(',').map(&:strip)

          row = [name, nil, 0, 0, id, id_address, gender, mobile, post_code, contact_address, nil, product_code, amount, nil, nil, 1, mobile, 1, product_code, business_code]
          wf.puts row.map(&:to_s).map{|str| str.encode(Encoding::GBK)}.join(",")
        end
      end
    end

    puts ">> Generate file: #{output}"

  end

  desc 'generate_xiaojin_details', "生成小金需要的《客户明细销售表》"
  long_desc <<-LONGDESC
    Parameters:

      from - 为记录"专业执行人"信息的文件地址，格式为 "姓名,身份证,手机号,性别,产品代码,购买金额"

    Examples:

      ruby lib/tasks/xiaojin.rb generate_xiaojin_details
        --from=/Users/wendi/Workspace/kaitong/baton-web/samples/xiaojin/专业执行人.csv
  LONGDESC
  option :from,     required: true
  def generate_xiaojin_details
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    today = Date.today.to_s.gsub('-','')
    out_filename = "xiaojin_客户销售明细表_#{today}.csv"
    output = File.join(File.expand_path("../../../tmp", __FILE__), out_filename)

    timestamp = Time.now.to_s.gsub(/[\-\s:\+]/, '')

    File.open(output, 'w') do |wf|

      File.open(options[:from], 'r') do |rf|
        rf.each_with_index do |line, i|
          next if line.empty?
          name, id, mobile, gender, product_code, amount = line.strip.split(',').map(&:strip)

          row = [timestamp, timestamp, product_code, amount.to_i*100, name, id, mobile, gender, '北京市', mobile, '100000', '北京市']
          wf.puts row.map(&:to_s).map{|str| str.encode(Encoding::GBK)}.join(",")
        end
      end
    end

    puts ">> Generate file: #{output}"

  end

  desc 'generate_xiaojin_contract', "生成小金需要的《产品合同模板》"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb generate_xiaojin_contract
        --from=/Users/wendi/Workspace/kaitong/baton-web/samples/guangjiaosuo/产品合同模板.html
  LONGDESC
  option :from, required: true
  def generate_xiaojin_contract
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    today = Date.today.to_s.gsub('-','')
    out_filename = "xiaojin_产品合同模板_#{today}.html"
    output = File.join(File.expand_path("../../../tmp", __FILE__), out_filename)

    content = File.read(options[:from])
    File.open(output, 'w') do |wf|
      wf.write content\
                .gsub('__contract_index__', '')\
                .gsub('__period_index__', '')\
                .gsub('__product_code__', '')
    end

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

  desc 'load_user_detail', "初始化客户资产明细"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb load_user_detail
        --from=/Users/wendi/Workspace/kaitong/baton-web/test/tasks/resources/xiaojin/客户资产明细.init.csv
  LONGDESC
  option :from, required: true
  def load_user_detail
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    load_rails

    CSV.foreach(options[:from]) do |row|
      next if row[0].empty?

      UserDetail.create(
        product_code: row[0],
        user_name: row[1],
        user_id_card: row[2],
        amount: row[3].to_i
      )
    end

    puts ">> Record user details into DB"
  end

  desc 'check_transfer_detail', "根据小金每天上传的《客户资产转让明细》，生成转让后客户资产信息，并与小金上传的《客户资产明细》做对比校验。无误后，更新 DB 中的客户资产信息。"
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb check_transfer_detail
        --transfer-detail=/Users/wendi/Workspace/kaitong/baton-web/test/tasks/resources/xiaojin/客户资产转让明细.csv
        --user-detail=/Users/wendi/Workspace/kaitong/baton-web/test/tasks/resources/xiaojin/客户资产明细.csv
  LONGDESC
  option :transfer_detail, required: true
  option :user_detail,     required: true
  def check_transfer_detail
    raise "Invalid <transfer_detail> file position: #{options[:transfer_detail]}" unless File.exist?(options[:transfer_detail])
    raise "Invalid <user_detail> file position: #{options[:user_detail]}" unless File.exist?(options[:user_detail])

    load_rails

    @user_details_cache = []

    CSV.foreach(options[:transfer_detail]) do |row|
      next if row[0].empty?

      product_code, amount, from_user, from_user_id, to_user, to_user_id = *row[2..-1]
      amount = amount.to_i

      from_ud = find_or_initialize_by(product_code, from_user, from_user_id, amount)
      to_ud = find_or_initialize_by(product_code, to_user, to_user_id, amount)

      from_ud.amount -= amount
      to_ud.amount   += amount

      @user_details_cache << from_ud unless already_in_cache?(from_ud.product_code, from_ud.user_id_card)
      @user_details_cache << to_ud   unless already_in_cache?(to_ud.product_code, to_ud.user_id_card)
    end

    failed = []
    CSV.foreach(options[:user_detail]) do |row|
      next if row[0].empty?

      product_code, user_name, user_id, amount = *row
      amount = amount.to_i

      user = find_in_cache_by(product_code, user_id)

      unless user.amount == amount
        failed << [user_name, user.amount, amount]
      end
    end

    if failed.blank?
      save_cache_in_db!
      puts ">> Validate succeed"
    else
      subject = "小金转让信息校验失败 #{Date.today}"
      body = {
        type: :table,
        stat: [ ['用户', '开通计算转让后用户资产', '小金提供转让后用户资产'] ] + failed
      }
      Notifier.notify(subject, body).deliver
      puts ">> Failed, sent messages"
    end
  end

  desc 'postman', 'test Notifier'
  long_desc <<-LONGDESC
    Examples:

      ruby lib/tasks/xiaojin.rb postman
  LONGDESC
  def postman
    load_rails

    Notifier.notify("Test", {type: :message, stat: "This a test mail"}).deliver
  end

  private

    def convert_file_encoding!(file, from="UTF-8", to="GBK")
      content = File.read(file, encoding:from)
      File.open(file, "w:#{to}:#{from}"){|wf| wf.write content }
    end

    def find_in_cache_by(product_code, user_id)
      @user_details_cache.detect{|ud| ud.product_code == product_code && ud.user_id_card == user_id}
    end

    def find_or_initialize_by(product_code, to_user, to_user_id, amount)
      find_in_cache_by(product_code, to_user_id)\
        || UserDetail.where(product_code: product_code, user_id_card: to_user_id).first \
        || UserDetail.new(product_code: product_code, user_name: to_user, user_id_card: to_user_id, amount: 0)
    end

    def already_in_cache?(product_code, user_id)
      find_in_cache_by(product_code, user_id).present?
    end

    def save_cache_in_db!
      @user_details_cache.map(&:save!)
    end
end

KaitongCli.start(ARGV)
