require 'test_helper'

class FileAgent
  class NameMappingTest < ActiveSupport::TestCase
    def test_parse
      GuangjiaosuoNameMapping.expects(:parse).with('hello world')
      NameMapping.parse(:guangjiaosuo, 'hello world')
    end
  end
end
