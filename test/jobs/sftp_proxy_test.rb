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

    SftpProxy.download_dir(from, to)

    files_in_sftp = nil
    SftpProxy.start{ |sftp| files_in_sftp = sftp.dir.entries(from).map{|e| e.name}.reject{|e| base_dir.include?(e)} }
    assert_equal files_in_sftp.to_set, files_in(to).to_set
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
