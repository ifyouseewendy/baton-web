require 'test_helper'

class GuangjiaosuoNameMappingTest < ActiveSupport::TestCase
  def test_parse
    assert_equal "产品信息表", FileAgent::GuangjiaosuoNameMapping.parse("/tmp/guangjiaosuo_产品信息表_20150507.xlsx")
    assert_equal "hello.txt", FileAgent::GuangjiaosuoNameMapping.parse("hello.txt")
  end
end
