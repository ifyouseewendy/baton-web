require 'test_helper'
require_relative 'enum_field_test'
require_relative 'status_check_test'

class TaskTest < ActiveSupport::TestCase
  include EnumFieldTest
  include StatusCheckTest

  def setup
    @task = @subject = Fabricate(:task)
  end

  def teardown
    Task.delete_all
  end

end
