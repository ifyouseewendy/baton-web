require 'test_helper'

class FileAgent
  class GuangjiaosuoNameMappingTest < ActiveSupport::TestCase
    def test_parse
      assert_equal "产品信息表", GuangjiaosuoNameMapping.parse("/tmp/guangjiaosuo_产品信息表_20150507.xlsx")
      assert_equal "hello.txt", GuangjiaosuoNameMapping.parse("hello.txt")
    end
  end
end
