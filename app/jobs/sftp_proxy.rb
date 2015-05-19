require 'net/sftp'

class SftpProxy
  class << self
    def start
      Net::SFTP.start *Rails.application.secrets.values_at(:sftp_address, :sftp_user) do |sftp|
        yield sftp
      end
    end

    def download
    end

    # Download from/a, from/b -> to/a, to/b. No nested dir support.
    def download_dir(from, to)
      start do |sftp|
        sftp.dir.foreach(from) do |file|
          next if file.name =~ /^\./
          sftp.download! File.join(from,file.name), File.join(to,file.name)
        end
      end
    end
  end
end
