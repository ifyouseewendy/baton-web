require 'test_helper'
require_relative 'enum_field_test'

class TaskTest < ActiveSupport::TestCase
  include EnumFieldTest

  def setup
    @task = @subject = Fabricate(:task)
  end

  def teardown
    Task.delete_all
  end
end
