require 'net/sftp'

class SftpProxy
  class << self
    def start
      Net::SFTP.start *Rails.application.secrets.values_at(:sftp_address, :sftp_user) do |sftp|
        yield sftp
      end
    end

    def download(type, from, to)
      Array.wrap self.public_send( "download_#{type}", from, to )
    end

    # Expecting from: 'dir/a.txt', to: 'dir'
    def download_file(from, to)
      file = Pathname.new(from).basename
      start do |sftp|
        sftp.download! from, File.join(to,file)
      end

      Pathname.new File.join(to,file)
    end

    # Download from/a, from/b -> to/a, to/b. No nested dir support.
    def download_dir(from, to)
      files = []

      start do |sftp|
        sftp.dir.foreach(from) do |file|
          next if file.name =~ /^\./
          sftp.download! File.join(from,file.name), File.join(to,file.name)
          files << Pathname(File.join(to,file.name))
        end
      end

      files.sort
    end
  end
end
