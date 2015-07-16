require 'test_helper'

class FileAgentTest < ActiveSupport::TestCase
  def setup
    @organization = :wendi
    local_test_dirs.map(&:mkpath)
    %w(download upload).each{|dir| local_test_dir.join(dir).mkpath}
  end

  def teardown
    local_test_dirs.map(&:rmtree)
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

  def test_download_test_env
    from  = "/home/#{@organization}_test/upload/test_dir/"
    to    = File.join( local_test_dir(env: :test), "upload" )
    file  = 'a.txt'

    fa = ::FileAgent.new(@organization, env: :test)

    ::SftpProxy.expects(:download_file).with( File.join(from,file), to)

    fa.download(
      :file,
      project_id: 'test_dir',
      date:       'test_dir',
      direction:  'upload',
      file:       file
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

  def test_upload_test_env
    dir  = Rails.root
    to    = "/home/#{@organization}_test/download/test_dir"
    from = dir.join('tmp').join("test-upload-#{SecureRandom.hex(4)}")

    ::SftpProxy.expects(:upload_file).with(from.to_s, to)

    fa = ::FileAgent.new(@organization, env: :test)
    fa.upload(
      :file,
      date:         'test_dir',
      organization:  @organization,
      file:          from.to_s
    )
  end

  private

    def local_test_dir(option = {env: :online})
      return Pathname.new(File.join( Rails.root, "public", "resources", "#{@organization}_test", "test_dir")) if option[:env] == :test
      Pathname.new(File.join( Rails.root, "public", "resources", @organization.to_s, "test_dir"))
    end

    def local_test_dirs
      [ local_test_dir, local_test_dir(env: :test) ]
    end
end

