require 'test_helper'

class FileAgentTest < ActiveSupport::TestCase
  def setup
    local_test_dir.mkpath
    %w(download upload).each{|dir| local_test_dir.join(dir).mkpath}
  end

  def teardown
    local_test_dir.rmtree
  end

  def test_download
    from  = "/home/wendi/download/test_dir/"
    to    = File.join( local_test_dir, "download" )
    file  = 'a.txt'

    ::SftpProxy.expects(:download_file).with( File.join(from,file), to)

    fa = ::FileAgent.new(:wendi)
    fa.download(
      :file,
      project_id: 'test_dir',
      date:       'test_dir',
      direction:  'download',
      file:       file
    )

    ::SftpProxy.expects(:download).with(:dir, from, to)

    fa = ::FileAgent.new(:wendi)
    fa.download(
      :dir,
      project_id: 'test_dir',
      date:       'test_dir',
      direction:  'download',
    )
  end

  def test_download_names_mapping_default
    file  = 'a.txt'

    fa = ::FileAgent.new(:wendi)
    files = fa.download(
      :file,
      project_id: 'test_dir',
      date:       'test_dir',
      direction:  'download',
      file:       file
    )

    assert_equal [file], fa.name_mapping(files)
  end

  private

    def local_test_dir
      @_local_test_dir ||= Pathname.new File.join( Rails.root, "public", "resources", "test_dir")
    end
end

