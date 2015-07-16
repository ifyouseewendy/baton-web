require 'net/sftp'

class SftpProxy
  class << self
    def start
      Net::SFTP.start *Rails.application.secrets.values_at(:sftp_address, :sftp_user) do |sftp|
        yield sftp
      end
    end

    def download(type, from, to)
      Array.wrap self.public_send( "download_#{type}", from, to)
    end

    # Expecting from: 'dir/a.txt', to: 'dir'
    def download_file(from, to)
      file = Pathname.new(from).basename
      source, target = from, File.join(to,file)

      start do |sftp|
        puts "--> Fetching from SFTP:#{target}"
        sftp.download! source, target
      end

      Pathname.new target.force_encoding(Encoding::UTF_8)
    end

    # Download from/a, from/b -> to/a, to/b. No nested dir support.
    def download_dir(from, to)
      files = []

      start do |sftp|
        sftp.dir.foreach(from) do |file|
          next if file.name =~ /^\./
          source, target = File.join(from,file.name), File.join(to,file.name)

          puts "--> Fetching from SFTP:#{target}"
          sftp.download! source, target

          files << Pathname.new(target.force_encoding(Encoding::UTF_8))
        end
      end

      files.sort
    end

    def upload(type, from, to)
      self.public_send( "upload_#{type}", from, to)
    end

    # Expecting from: 'dir/a.txt', to: 'dir'
    def upload_file(from, to)
      file = Pathname.new(from).basename
      start do |sftp|
        puts "--> Uploading to SFTP:#{File.join(to,file)}"

        sftp.upload! from.to_s, File.join(to,file).force_encoding('Binary') # net-sftp transfers binary
      end

      Pathname.new File.join(to,file)
    end

    def upload_dir(from, to)
      raise NotImplementedError
      # https://github.com/net-ssh/net-sftp/blob/master/lib/net/sftp/operations/upload.rb#L19-L34
    end

    def ls(path)
      files = []

      start do |sftp|
        files = sftp.dir.entries(path.to_s).map{|e| e.name.force_encoding('UTF-8') }
      end

      files.reject{|e| %w(. ..).include?(e)}
    end

    private

      def fake_download_file(path)
        FileUtils.mkdir_p( Pathname(path).dirname )
        File.open(path, 'w'){|of| of.write "This is a test file, buddy"}

        Pathname(path)
      end

      def fake_upload_file
      end

  end
end
