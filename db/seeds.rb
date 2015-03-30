def remove_db_data
  [User, Product, Order, Platform, Project, HourlyStat].map{|m| m.delete_all}
end

def remove_resource_files
  FileUtils.rm_rf( "#{Rails.root}/db/resources/xiaojin" )
end

def generate_resource_files
  ['20150320', '20150321'].each do |date|
    dir = "#{Rails.root}/db/resources/xiaojin/upload/#{date}"
    FileUtils.mkdir_p(dir)

    (10..20).map(&:to_s).each do |hour|
      File.open("#{dir}/xiaojin_实时客户明细销售表_#{date}_#{hour}.csv", 'w') do |of|
        ( rand(40)+10 ).times do
          serial_number   = "serial_#{SecureRandom.hex(5)}"
          generated_at    = (Date.parse('20150101') + 10.hours + rand(60).minutes).to_s(:db).gsub(/[-:\s]/,'')
          user_name       = "user_#{SecureRandom.hex(4)}"
          id_card_number  = "id_#{SecureRandom.hex(10)}"
          product_code    = ( 100000+rand(10) ).to_s
          user_share      = ( 1000+rand(4000) ).to_s
          mobile          = ( 18600000000+rand(9999) ).to_s

          of.puts [serial_number, generated_at, product_code, user_share, user_name, id_card_number, mobile].join(",")
        end
      end
    end
  end
end

def generate_db_data
  a = HourlyOrder.new('xiaojin', 'alpha')

  def a.root_path
    File.join(Rails.root, "db/resources")
  end

  def Date.today
    Date.parse("2015-03-20")
  end

  a.check

  b = HourlyOrder.new('xiaojin', 'alpha')

  def b.root_path
    File.join(Rails.root, "db/resources")
  end

  def Date.today
    Date.parse("2015-03-21")
  end

  b.check
end

remove_db_data
remove_resource_files
generate_resource_files
generate_db_data

