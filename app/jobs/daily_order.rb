require 'csv'

class DailyOrder
  # Check daily order statistics from Internet platform
  #
  #   Add left orders of HourlyOrder

  attr_accessor :platform

  def initialize(platform)
    @platform = Platform.find_or_create_by(name: platform)
  end

  def check
    puts "--> [#{Time.now}] <DailyOrder> Start checking"

    unchecked_files.each do |file|
      fn = File.join(source_path, file)
      parse_and_create_from fn
      puts "--> [#{Time.now}] <DailyOrder> parsed #{file}"

      backup fn
    end

    puts "<-- [#{Time.now}] <DailyOrder> End"
  end

  def backup(fn)
    target = File.join "#{Dir.home}", 'backup', platform.name
    FileUtils.mkdir_p target
    `cp #{fn} #{target}`
  end

  def parse_and_create_from(fn)
    count = 0
    CSV.foreach(fn) do |row|
      next if Order.where(serial_number: row[0]).count > 0

      user = User.find_or_create_by(id_card_number: row[3]) do |u|
        u.name = row[2]
        u.id_card_number = row[3]
        u.mobile = row[6]
      end

      product = Product.find_or_create_by(code: row[4])

      Order.create(
        user:           user,
        product:        product,
        platform:       platform,
        serial_number:  row[0],
        generated_at:   Time.parse(row[1]),
        user_share:     row[5].to_i
      )

      count += 1
    end

    date, hour = parse_name File.basename(fn)
    HourlyStat.create(date: date, hour: hour, count: count)
  end

  private

    def source_path
      @_source_path ||= File.join(root_path, platform.name, 'upload', Date.today.to_s.gsub('-',''))
    end

    # Test stub use
    def root_path
      @_root_path ||= "/home"
    end

    def unchecked_files
      @_unchecked_files ||= Dir.entries(source_path).select do |fn|
        fn =~ /天级/ && parse_name(fn) == Date.today.to_s
      end
    end

    def parse_name(fn)
      Date.parse(fn.split('.')[0].split('_')[-1]).to_s rescue nil
    end
end