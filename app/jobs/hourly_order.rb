require 'csv'

class HourlyOrder
  # Check hourly order statistics from Internet platform
  #
  #   Create new orders.

  attr_accessor :platform, :project

  def initialize(platform, project)
    @platform = Platform.find_or_create_by(name: platform)
    @project  = Project.find_or_create_by(platform: @platform, name: project)
  end

  def check
    puts "--> [#{Time.now}] <HourlyOrder> Start checking"

    unchecked_files.each do |file|
      fn = File.join(source_path, file)
      parse_and_create_from fn
      puts "--> [#{Time.now}] <HourlyOrder> parsed #{file}"

      backup fn
    end

    puts "<-- [#{Time.now}] <HourlyOrder> End"
  end

  def backup(fn)
    target = File.join "#{Dir.home}", 'backup', platform.name
    FileUtils.mkdir_p target
    `cp #{fn} #{target}`
  end

  def parse_and_create_from(fn)
    order_count, share_count = 0, 0
    CSV.foreach(fn) do |row|
      next if Order.where(serial_number: row[0]).count > 0

      user = User.find_or_create_by(id_card_number: row[3]) do |u|
        u.name = row[2]
        u.id_card_number = row[3]
        u.mobile = row[6]
      end

      product = Product.find_or_create_by(code: row[4], project: project)

      Order.create(
        user:           user,
        project:        project,
        product:        product,
        serial_number:  row[0],
        generated_at:   Time.parse(row[1]),
        user_share:     row[5].to_i
      )

      order_count += 1
      share_count += row[5].to_i
    end

    date, hour = parse_name File.basename(fn)
    HourlyStat.create(
      project: self.project,
      date: date,
      hour: hour,
      order_count: order_count,
      share_count: share_count
    )
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
      @_unchecked_files = Dir.entries(source_path).select{|fn| fn =~ /实时/}.reduce([]) do |ret, fn|
        date, hour = parse_name(fn)
        if HourlyStat.where(project: self.project, date: date, hour: hour).count > 0
          ret
        else
          ret << fn
        end
      end
    end

    def parse_name(fn)
      date, hour = fn.split('.')[0].split('_')[-2,2]
      [Date.parse(date).to_s, hour.to_i]
    end
end
