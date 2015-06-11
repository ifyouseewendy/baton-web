# This is a temp job, used in config/schedule.rb, copyed from lib/task/xiaojin.rb
class XiaojinJob
  def check_transfer_detail
    today = Date.today.to_s.gsub('-','')
    options = {}
    # options[:transfer_detail]  ||= "/Users/wendi/Workspace/kaitong/baton-web/samples/xiaojin/客户资产转让明细.csv"
    # options[:user_detail]      ||= "/Users/wendi/Workspace/kaitong/baton-web/samples/xiaojin/客户资产明细.csv"
    options[:transfer_detail]  ||= "/home/xiaojin/upload/#{today}/xiaojin_客户资产转让明细_#{today}.csv"
    options[:user_detail]      ||= "/home/xiaojin/upload/#{today}/xiaojin_客户资产明细_#{today}.csv"

    proc { puts "[#{Time.now.to_s(:db)}] ** No such file: #{options[:transfer_detail]}"; return }.call unless File.exist?(options[:transfer_detail])
    proc { puts "[#{Time.now.to_s(:db)}] ** No such file: #{options[:user_detail]}"; return }.call     unless File.exist?(options[:user_detail])

    @user_details_cache = []

    puts "[#{Time.now.to_s(:db)}] --> Start parsing transfer detail (#{CSV.foreach(options[:transfer_detail]).count} records)"

    CSV.foreach(options[:transfer_detail]) do |row|
      next if row.blank?

      product_code, amount, from_user, from_user_id, to_user, to_user_id = *row[2..-1]
      amount = amount.to_i

      from_ud = find_or_initialize_by(product_code, from_user, from_user_id, amount)
      to_ud = find_or_initialize_by(product_code, to_user, to_user_id, amount)

      from_ud.amount -= amount
      to_ud.amount   += amount

      @user_details_cache << from_ud unless already_in_cache?(from_ud.product_code, from_ud.user_id_card)
      @user_details_cache << to_ud   unless already_in_cache?(to_ud.product_code, to_ud.user_id_card)
    end

    puts "[#{Time.now.to_s(:db)}] --> Start parsing user detail (#{CSV.foreach(options[:user_detail]).count} records)"

    failed = []
    CSV.foreach(options[:user_detail]) do |row|
      next if row.blank?

      product_code, user_name, user_id, amount = *row
      amount = amount.to_i

      user = find_in_cache_by(product_code, user_id)

      unless user.amount == amount
        failed << [product_code, user_name, user.amount, amount]
      end
    end

    if failed.blank?
      save_cache_in_db!
      puts "[#{Time.now.to_s(:db)}] <-- Validate succeed"
    else
      subject = "小金转让信息校验失败 #{Date.today}"
      body = {
        type: :table,
        stat: [ ['产品代码', '用户', '开通计算转让后用户资产', '小金提供转让后用户资产'] ] + failed
      }
      Notifier.notify(subject, body).deliver
      puts "[#{Time.now.to_s(:db)}] <-- Failed, sent messages"
    end
  end

  private

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
