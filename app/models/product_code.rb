# Public: Product code presentation by 6 length default, uniform upcase,
# 0-9A-Z charset successor, 0->1, 9->A, Z->0.
#
# Examples
#
#   pc = ProductCode.new('k000AZ')
#
#   pc.next # => 'K000B0'
#   pc.to_s # => '07X1AZ'
#
#   pc.next!
#   pc.to_s # => '07X1B0'
class ProductCode
  CHARSET = ('0'..'9').to_a + ('A'..'Z').to_a

  attr_accessor :code, :length

  def initialize(code, length = 6)
    @code = code.upcase
    @length = length

    check_code
  end

  # Public: Generate the next code based on 0-9A-Z charset.
  #
  # Examples
  #
  #   "07X1AZ".next                   # => "07X1BA"
  #   ProductCode.new("07X1AZ").next  # => "07X1B0"
  #
  # Returns next String code.
  def next
    _code = ( code.to_i(36) + 1 ).to_s(36).rjust(length, '0').upcase
    raise "Overflow Code Length: #{code} -> #{_code}" if _code.length > length

    _code
  end

  def next!
    self.code = self.next
  end

  def to_s
    code
  end

  private

    def check_code
      check_length
      check_charset
    end

    def check_length
      raise "Invalid Code Length: #{code.length}. Default code length is 6, pleas pass the custom length into #initialize(code, length)"\
        if length != code.length
    end

    def check_charset
      code.each_char{|c| raise "Invalid Code Charset: #{c}. Valid charset is 0-9, A-Z" if !CHARSET.include?(c) }
    end
end
