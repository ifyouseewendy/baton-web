require 'test_helper'
require_relative 'enum_field_test'

class StepTest < ActiveSupport::TestCase
  include EnumFieldTest

  def setup
    @step = @subject = Fabricate(:step)
  end

  def teardown
    @step.delete
  end
end
