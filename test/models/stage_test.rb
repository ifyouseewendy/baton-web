require 'test_helper'
require_relative 'enum_field_test'

class StageTest < ActiveSupport::TestCase
  include EnumFieldTest

  def setup
    @stage = @subject = Fabricate(:stage)
  end

  def teardown
    Stage.delete_all
  end
end
