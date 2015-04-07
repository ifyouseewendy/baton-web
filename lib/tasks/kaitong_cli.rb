require 'thor'
require 'csv'

class KaitongCli < Thor
  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
  end

  desc ''
  option :from,   required: true
  option :column, required: true
  option :code,   required: true
  def xiaojin
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    output = "#{options[:from]}.out.csv"
    code = ProductCode.new(options[:code])
    File.open(output, 'w') do |of|
      pos = 0
      CSV.foreach(options[:from]) do |row|
        pos += 1

        of.puts (row[0..(column-1)] + [code.to_s] + row[(column+1)..-1]).join(',')
        record_relation(row[column], code)

        if pos == 200
          pos = 0
          code.next!
        end
      end
    end

    puts "--> Generate file: #{outpu}"
    puts "    Code range: #{options[:code]} - #{code}"
  end

  private

    def record_relation(stat, code)
      prd = Product.find_or_create_by(code: code.to_s)
      prd.property_serial << stat
      prd.save!
    end
end

KaitongCli.start(ARGV)
