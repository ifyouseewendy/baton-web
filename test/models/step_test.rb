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

  module ::TestJob
    class Step007
      def run(step, args); {status: :succeed}; end
    end
  end

  def test_run
    project = stub(id: 'test', env: :test)
    @step.stubs(:project).returns(project)
    @step.stubs(:recipe).returns(:test)
    @step.stubs(:job_id).returns('007')

    @step.run( {name: "Jissbon"} )

    assert_equal :succeed, @step.result[:status]
    assert @step.done?
  end

  def test_add_file
    project = stub(id: 'test')
    @step.stubs(:project).returns(project)

    filename = Tempfile.create('_').path

    assert_difference ->{ @step.files.count }, 2 do
      @step.add_file(filename, :test)
      @step.add_file(filename, :test)
    end

    assert_difference -> { @step.files.count }, -1 do
      @step.add_file(filename, :test, override: true)
    end
  end
end
