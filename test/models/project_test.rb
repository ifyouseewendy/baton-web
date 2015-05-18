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
    Project.delete_all
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
end
