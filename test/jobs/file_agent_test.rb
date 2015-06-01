require 'test_helper'

class FileAgentTest < ActiveSupport::TestCase
  def setup
    @organization = :wendi
    local_test_dir.mkpath
    %w(download upload).each{|dir| local_test_dir.join(dir).mkpath}
  end

  def teardown
    local_test_dir.rmtree
  end

  def test_download
    from  = "/home/#@organization/upload/test_dir/"
    to    = File.join( local_test_dir, "upload" )
    file  = 'a.txt'

    ::SftpProxy.expects(:download_file).with( File.join(from,file), to)

    fa = ::FileAgent.new(@organization)
    fa.download(
      :file,
      project_id: 'test_dir',
      date:       'test_dir',
      direction:  'upload',
      file:       file
    )

    ::SftpProxy.expects(:download).with(:dir, from, to)

    fa = ::FileAgent.new(@organization)
    fa.download(
      :dir,
      project_id: 'test_dir',
      date:       'test_dir',
      direction:  'upload',
    )
  end

  def test_download_names_mapping_default
    file  = 'a.txt'

    fa = ::FileAgent.new(@organization)
    fa.download(
      :file,
      project_id: 'test_dir',
      date:       'test_dir',
      direction:  'upload',
      file:       file
    )

    assert_equal [file], fa.names
  end

  def test_upload
    dir  = Rails.root
    to    = "/home/#@organization/download/test_dir"

    from = dir.join('tmp').join("test-upload-#{SecureRandom.hex(4)}")
    FileUtils.cp dir.join('Gemfile'), from

    ::SftpProxy.expects(:upload_file).with(from.to_s, to)

    fa = ::FileAgent.new(@organization)
    fa.upload(
      :file,
      date:         'test_dir',
      organization:  @organization,
      file:          from.to_s
    )
  end

  private

    def local_test_dir
      @_local_test_dir ||= Pathname.new File.join( Rails.root, "public", "resources", @organization.to_s, "test_dir")
    end
end

