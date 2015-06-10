require 'test_helper'
require_relative 'enum_field_test'
require_relative 'status_check_test'

class ProjectTest < ActiveSupport::TestCase
  include EnumFieldTest
  include StatusCheckTest

  def setup
    @project = @subject = Fabricate(:project)
  end

  def teardown
    @project.delete
  end

  def test_tasks_entry
    assert_equal \
      @project.stages.map(&:tasks).flatten.map(&:name),
      @project.tasks.map(&:name)
  end

  def test_steps_entry
    assert_equal \
      @project.tasks.map(&:steps).flatten.map(&:name),
      @project.steps.map(&:name)
  end

  def test_dependent_destroy
    @project.delete
    assert_equal [0]*4, [Project, Stage, Task, Step].map(&:count)
  end

  def test_current_stage
    first, second = @project.stages.values_at(0, 1)
    assert_equal first, @project.current_stage

    first.done!
    assert_equal second, @project.current_stage
  end

  def test_class_build_by
    JingdongRecipe.instance.expects(:build)
    Project.build_by(:jingdong)
  end

  def test_get_serial
    assert @project.serial.nil?
    assert @project.platform.nil?

    Date.stubs(:today).returns("20150101")
    assert "20150101", @project.get_serial

    @project.platform = 'jingdong'
    @project.get_serial
    assert "20150101_001", @project.serial
  end

end
