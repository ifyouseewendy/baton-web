require 'test_helper'

class SftpProxyTest < ActiveSupport::TestCase
  def setup
    @organization = :wendi
    local_test_dir.mkpath
    %w(download upload).each{|dir| local_test_dir.join(dir).mkpath}
  end

  def teardown
    local_test_dir.rmtree
  end

  def test_start
    proxy = nil
    SftpProxy.start{|sftp| proxy = sftp}

    assert_equal Net::SFTP::Session, proxy.class
  end

  def test_download
    SftpProxy.expects(:download_file).with('from', 'to')
    ret = SftpProxy.download(:file, 'from', 'to')
    assert_kind_of(Array, ret)

    SftpProxy.expects(:download_dir).with('from', 'to')
    SftpProxy.download(:dir, 'from', 'to')
  end

  def test_download_file
    from  = "/home/#@organization/upload/test_dir"
    to    = File.join( local_test_dir, "download" )
    file = 'a.txt'

    target_file = Pathname.new(File.join(to, file))

    refute target_file.exist?

    file = SftpProxy.download_file(File.join(from,file), to)

    assert target_file.exist?
    assert_equal target_file, file
  end

  def test_download_dir
    from  = "/home/#@organization/upload/test_dir"
    to    = File.join( local_test_dir, "download" )

    assert_empty files_in(to)

    files = SftpProxy.download_dir(from, to)
      # ["/Users/#@organization/Workspace/kaitong/baton-web/public/resources/test_dir/download/a.txt"]
    files = files.map(&:basename).map(&:to_s)
      # ["a.txt"]

    assert_equal files, files_in(to).sort
  end

  def test_upload
    dir  = Rails.root
    to    = "/home/#@organization/download/test_dir"

    from = dir.join('tmp').join("test-upload-中文-#{SecureRandom.hex(4)}")
    FileUtils.cp dir.join('Gemfile'), from

    refute SftpProxy.ls(to).include?( Pathname(from).basename.to_s )

    SftpProxy.upload(:file, from, to)
    assert SftpProxy.ls(to).include?( Pathname(from).basename.to_s )

    FileUtils.rm from
  end

  private

    def files_in(dir)
      Pathname(dir).entries.reject{|p| base_dir.include?(p.to_s) }.map(&:to_s)
    end

    def base_dir
      @_base_dir = %w(. ..)
    end

    def local_test_dir
      @_local_test_dir ||= Pathname.new File.join( Rails.root, "public", "resources", "test_dir")
    end
end
