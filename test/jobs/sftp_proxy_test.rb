require 'test_helper'

class SftpProxyTest < ActiveSupport::TestCase
  def setup
    FileUtils.mkdir_p(local_test_dir)
    %w(download upload).each{|dir| FileUtils.mkdir_p File.join(local_test_dir, dir) }
  end

  def teardown
    FileUtils.rm_rf(local_test_dir)
  end

  def test_start
    proxy = nil
    SftpProxy.start{|sftp| proxy = sftp}

    assert_equal Net::SFTP::Session, proxy.class
  end

  def test_download_dir
    from  = "/home/wendi/download/test_dir"
    to    = File.join( local_test_dir, "download" )

    assert_empty files_in(to)

    files = SftpProxy.download_dir(from, to)
      # ["/Users/wendi/Workspace/kaitong/baton-web/public/resources/test_dir/download/a.txt"]
    files = files.map{|fn| File.split(fn) }.map{|fn| fn[1]}
      # ["a.txt"]

    assert_equal files, files_in(to).sort
  end

  private

    def files_in(dir)
      Pathname(dir).entries.reject{|p| base_dir.include?(p.to_s) }.map(&:to_s)
    end

    def base_dir
      @_base_dir = %w(. ..)
    end

    def local_test_dir
      File.join( Rails.root, "public", "resources", "test_dir")
    end
end
