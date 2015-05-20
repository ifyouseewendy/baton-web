require 'net/sftp'

class SftpProxy
  class << self
    def start
      Net::SFTP.start *Rails.application.secrets.values_at(:sftp_address, :sftp_user) do |sftp|
        yield sftp
      end
    end

    def download(file, from, to)
      start do |sftp|
        sftp.download! File.join(from,file), File.join(to,file)
      end

      File.join(to,file)
    end

    # Download from/a, from/b -> to/a, to/b. No nested dir support.
    def download_dir(from, to)
      files = []

      start do |sftp|
        sftp.dir.foreach(from) do |file|
          next if file.name =~ /^\./
          sftp.download! File.join(from,file.name), File.join(to,file.name)
          files << File.join(to,file.name)
        end
      end

      files.sort
    end
  end
end
