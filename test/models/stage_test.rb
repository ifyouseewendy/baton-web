require 'test_helper'
require_relative 'enum_field_test'
require_relative 'status_check_test'

class StageTest < ActiveSupport::TestCase
  include EnumFieldTest
  include StatusCheckTest

  def setup
    @stage = @subject = Fabricate(:stage)
  end

  def teardown
    Stage.delete_all
  end

  def test_steps_entry
    assert_equal @stage.tasks.map(&:steps).flatten.map(&:name), @stage.steps.map(&:name)
  end

end
