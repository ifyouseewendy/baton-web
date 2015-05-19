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
    @stage.delete
  end

  def test_steps_entry
    assert_equal @stage.tasks.map(&:steps).flatten.map(&:name), @stage.steps.map(&:name)
  end

  def test_current_task
    first, second = @stage.tasks.values_at(0, 1)
    assert_equal first, @stage.current_task

    first.done!
    assert_equal second, @stage.current_task
  end

  def test_progress
    task_count = @stage.tasks.to_a.count
    assert_equal "1 / #{task_count}", @stage.progress

    @stage.tasks.first.done!
    assert_equal "2 / #{task_count}", @stage.progress
  end

end
