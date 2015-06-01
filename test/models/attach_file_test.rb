require 'test_helper'

class AttachFileTest < ActiveSupport::TestCase

  def setup
    @attach_file = Fabricate(:attach_file)
    @step = @attach_file.step
  end

  def teardown
    @step.delete
  end

  def test_store_dir
    @attach_file.organization = :jingdong
    project = stub(id: 'test')
    @attach_file.stubs(:project).returns(project)
    @attach_file.file = File.open( Tempfile.new('_') )
    @attach_file.save

    assert_equal "/resources/jingdong/test/download", Pathname(@attach_file.file.url).dirname.to_s
  end
end
