require 'bigdecimal'

# Public: A calculator aims handling arithmatic precision and
# saving the result with 2 points truncated decimal.
#
# Examples
#
#   190000 * 0.0783
#   # => 14876.999999999998
#   190000 * 783 / 10000
#   # => 14877
#
#   cal = RateCalculator.new(190000, 0.0783)
#   cal.run
#   # => 14877.0
#
#
#   195555 * 0.0783
#   # => 15311.956499999998
#
#   cal = RateCalculator.new(195555, 0.0783)
#   # => 15311.95
#
# Returns a BigDecimal
class RateCalculator
  attr_reader :base, :rate

  def initialize(base, rate)
    @base = BigDecimal(base.to_s)
    @rate = BigDecimal(rate.to_s)
  end

  def run
    BigDecimal.save_rounding_mode do
      BigDecimal.mode(BigDecimal::ROUND_MODE, :truncate)
      (base*rate).round(2)
    end
  end
end

