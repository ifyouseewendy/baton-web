require 'test_helper'

class RateCalculatorTest < ActiveSupport::TestCase
  def test_precision
    assert_equal 14877.0, RateCalculator.new(190000, 0.0783).run.to_f
  end

  def test_truncate
    assert_equal 15311.95, RateCalculator.new(195555, 0.0783).run.to_f
  end
end
