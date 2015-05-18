require 'test_helper'
require_relative 'enum_field_test'

class ProjectTest < ActiveSupport::TestCase
  include EnumFieldTest

  def setup
    @project = @subject = Fabricate(:project)
  end

  def teardown
    Project.delete_all
  end

  def test_hello
    binding.pry
  end
end
