# Compared to SftpProxy
#   + params handling
#   + naming
class FileAgent
  attr_reader :platform

  def initialize(platform)
    @platform = platform
  end

  def download(type, args)
    from, to = server_path(args), local_path(args)

    ::SftpProxy.download(type, from, to)
  end

  private

    def server_path(args)
      assert_present_keys(args, :date, :dir)

      dir, file = args.values_at(:dir, :file)
      date = args.fetch(:date, Date.today.to_s.gsub('-', '') )

      "/home/#{platform}/#{dir}/#{date}/#{file}"
    end

    def local_path(args)
      assert_present_keys(args, :dir, :project_id)

      dir, project_id = args.values_at(:dir, :project_id)
      to_dir = Pathname.new File.join(Rails.root, "public", "resources", project_id, dir)
      to_dir.mkpath

      to_dir.to_s
    end

    def assert_present_keys(ha, *keys)
      keys.each{|k| ha.fetch(k){ raise "No #{k} passed." }}
    end
end
