require 'test_helper'

class NameMappingTest < ActiveSupport::TestCase
  def test_parse
    FileAgent::GuangjiaosuoNameMapping.expects(:parse).with('hello world')
    FileAgent::NameMapping.parse(:guangjiaosuo, 'hello world')
  end
end
