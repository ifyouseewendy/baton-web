require 'net/sftp'

class SftpProxy
  class << self
    def start
      Net::SFTP.start *Rails.application.secrets.values_at(:sftp_address, :sftp_user) do |sftp|
        yield sftp
      end
    end

    def download(type, from, to, options = {env: :online})
      Array.wrap self.public_send( "download_#{type}", from, to, options )
    end

    # Expecting from: 'dir/a.txt', to: 'dir'
    def download_file(from, to, options = {env: :online})
      file = Pathname.new(from).basename
      start do |sftp|
        source, target = from, File.join(to,file)
        puts "--> Fetching from SFTP:#{target}"

        if options[:env] == :online
          sftp.download! source, target
        else
          fake_download_file(source)
        end
      end

      Pathname.new File.join(to,file).force_encoding(Encoding::UTF_8)
    end

    # Download from/a, from/b -> to/a, to/b. No nested dir support.
    def download_dir(from, to, options = {env: :online})
      files = []

      start do |sftp|
        sftp.dir.foreach(from) do |file|
          next if file.name =~ /^\./

          source, target = File.join(from,file.name), File.join(to,file.name)
          puts "--> Fetching from SFTP:#{target}"

          if options[:env] == :online
            sftp.download! source, target
          else
            fake_download_file(source)
          end

          files << Pathname.new(target.force_encoding(Encoding::UTF_8))
        end
      end

      files.sort
    end

    def upload(type, from, to, options = {env: :online})
      self.public_send( "upload_#{type}", from, to, options )
    end

    # Expecting from: 'dir/a.txt', to: 'dir'
    def upload_file(from, to, options = {env: :online})
      file = Pathname.new(from).basename
      start do |sftp|
        puts "--> Uploading to SFTP:#{File.join(to,file)}"

        if options[:env] == :online
          sftp.upload! from.to_s, File.join(to,file).force_encoding('Binary') # net-sftp transfers binary
        else
          fake_upload_file
        end
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
        File.open(path, 'w'){|of| of.write "This is a test file, buddy"}
      end

      def fake_upload_file
      end

  end
end
