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

  def test_steps
    assert_equal @stage.tasks.map(&:steps).flatten.map(&:name), @stage.steps.map(&:name)
  end
end
