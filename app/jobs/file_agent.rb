# Compared to SftpProxy
#   + params handling
#   + naming
class FileAgent
  attr_reader :platform

  def initialize(platform)
    @platform = platform
  end

  # Public: Download file or dir through SftpProxy
  #
  # type - Symbol used to identify :file or :dir
  # args - The Hash options used to identify server and local path.
  #        :date - Server path param, format: '20150501'
  #        :direction  - Used to identify :download or :upload
  #        :project_id - Local path param
  #        :file - File name. Optional when download a dir.
  #
  # Examples
  #
  #   fa = ::FileAgent.new(:jingdong)
  #   fa.download(
  #     :file,
  #     project_id: 'project_id',
  #     date:       '20150501',
  #     direction:  'download',
  #     file:       'a.txt'
  #    )
  #   # from server-side  "/home/jingdong/download/20150501/a.txt"
  #   # to local-side     "#{Rails.root}/public/resources/project_id/download/a.txt"
  #
  #   fa.download(
  #     :dir,
  #     project_id: 'project_id',
  #     date:       '20150501',
  #     direction:  'download'
  #    )
  #   # from server-side  "/home/jingdong/download/20150501"
  #   # to local-side     "#{Rails.root}/public/resources/project_id/download"
  #
  # Returns an Array of files.
  def download(type, args)
    from, to = server_path(args), local_path(args)

    ::SftpProxy.download(type, from, to)
  end

  def name_mapping(files)
    files.map(&:basename).map(&:to_s).map{|fn| NameMapping.parse(platform, fn)}
  end

  private

    def server_path(args)
      assert_present_keys(args, :date, :direction)

      direction, file = args.values_at(:direction, :file)
      date = args.fetch(:date, Date.today.to_s.gsub('-', '') )

      "/home/#{platform}/#{direction}/#{date}/#{file}"
    end

    def local_path(args)
      assert_present_keys(args, :direction, :project_id)

      direction, project_id = args.values_at(:direction, :project_id)
      to_dir = Pathname.new File.join(Rails.root, "public", "resources", project_id, direction)
      to_dir.mkpath

      to_dir.to_s
    end

    def assert_present_keys(ha, *keys)
      keys.each{|k| ha.fetch(k){ raise "No #{k} passed." }}
    end

end
