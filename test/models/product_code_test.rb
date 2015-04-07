require 'test_helper'

class ProductCodeTest < ActiveSupport::TestCase
  def test_validate_on_length
    assert_raises(RuntimeError, "Invalid Code Length") do
      ProductCode.new('12345')
    end

    assert_raises(RuntimeError, "Invalid Code Length") do
      ProductCode.new('1234567')
    end

    assert_silent do
      ProductCode.new('123456')
    end

    assert_silent do
      ProductCode.new('12345678', 8)
    end
  end

  def test_validate_on_charset
    assert_silent do
      ProductCode.new('07x1aZ')
    end

    assert_raises(RuntimeError, "Invalid Code Charset") do
      ProductCode.new('12345-')
    end
  end

  def test_uniform_to_upcase
    assert_equal "07X1AZ", ProductCode.new('07x1aZ').to_s
  end

  def test_next
    pc = ProductCode.new('07x1aZ')
    assert_equal "07X1B0", pc.next.to_s
    assert_equal "07X1AZ", pc.to_s

    assert_raises(RuntimeError, "Overflow Code Length") do
      ProductCode.new("zzZzzZ").next
    end
  end

  def test_next!
    pc = ProductCode.new('07x1aZ')
    assert_equal "07X1B0", pc.next!.to_s
    assert_equal "07X1B0", pc.to_s

    assert_raises(RuntimeError, "Overflow Code Length") do
      ProductCode.new("zzZzzZ").next!
    end
  end
end
