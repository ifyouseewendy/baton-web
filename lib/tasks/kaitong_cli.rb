require 'thor'
require 'csv'

class KaitongCli < Thor
  ENV['RAILS_ENV'] ||= 'development'
  require File.expand_path('config/environment.rb')

  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
  end

  MAX_CODE_CAPACITY = 200

  desc 'xiaojin', ''
  option :from,   required: true
  option :column, type: :numeric, required: true
  option :code,   required: true
  def xiaojin
    raise "Invalid <from> file position: #{options[:from]}" unless File.exist?(options[:from])

    column = options[:column]
    output = "#{options[:from]}.out.csv"
    code = ProductCode.new(options[:code])
    File.open(output, 'w') do |of|
      pos = 0
      CSV.foreach(options[:from]) do |row|
        pos += 1

        next if row[0].blank?

        of.puts (row[0..(column-1)] + [code.to_s] + row[(column+1)..-1]).join(',')
        record_relation(row[column], code)

        if pos == MAX_CODE_CAPACITY
          pos = 0
          code.next!
        end
      end
    end

    puts "--> Generate file: #{output}"
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
