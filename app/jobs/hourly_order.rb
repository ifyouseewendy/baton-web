require 'csv'

class HourlyOrder
  # Check hourly order statistics from Internet platform

  attr_accessor :platform, :count

  def initialize(platform)
    @platform = Platform.find_or_create_by(name: platform)
    @count = 0
  end

  def check
    puts "--> [#{Time.now}] <HourlyOrder> Start"

    files = find_new_files
    if files.blank?
      puts "--> [#{Time.now}] <HourlyOrder> No new files"
      return
    end

    files.each do |csv|
      parse_and_create_from File.join(source_path, csv)
    end

    puts "--> [#{Time.now}] <HourlyOrder> parsed #{self.count} records"
  end

  def parse_and_create_from(csv)
    CSV.foreach(csv) do |row|
      next if Order.where(serial_number: row[0]).count > 0

      user = User.find_or_create_by(id_card_number: row[3]) do |u|
        u.name = row[2]
        u.id_card_number = row[3]
        u.mobile = row[6]
      end

      product = Product.find_or_create_by(code: row[4])

      order = Order.create(
        user:           user,
        product:        product,
        platform:       platform,
        serial_number:  row[0],
        generated_at:   Time.parse(row[1]),
        user_share:     row[5].to_i
      )

      self.count += 1
    end
  end

  private

    def source_path
      @_source_path ||= File.join(root_path, platform.name, 'upload', Date.today.to_s.gsub('-',''))
    end

    # Test stub use
    def root_path
      @_root_path ||= "/home"
    end

    def find_new_files
      new_files = []
      Dir.entries(source_path).each do |f|
        next if f == '.' || f == '..'
        next if f.split('.')[1] == 'checked'

        new_files << f
      end
      new_files
    end

end
