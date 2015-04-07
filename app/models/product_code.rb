class ProductCode
  # TODO Comment based on Tomdoc

  CHARSET = ('0'..'9').to_a + ('A'..'Z').to_a

  attr_accessor :code, :length

  def initialize(code, length = 6)
    @code = code.upcase
    @length = length

    check_code
  end

  def next
    # Why not use `code.next`?
    #
    # "K0001Z".next # => "K0002A"
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
