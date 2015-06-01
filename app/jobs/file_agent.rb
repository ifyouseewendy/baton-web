# Compared to SftpProxy
#   + params handling
#   + naming
class FileAgent
  attr_accessor :organization, :files

  def initialize(organization)
    @organization = organization
    @files        = []
  end

  # Public: Download file or dir through SftpProxy
  #
  # type - Symbol used to identify :file or :dir
  # args - The Hash options used to identify server and local path.
  #        :date - Server path param, format: '2015-05-01'
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
  #     date:       '2015-05-01',
  #     direction:  'download',
  #     file:       'a.txt'
  #    )
  #   # from server-side  "/home/jingdong/download/20150501/a.txt"
  #   # to local-side     "#{Rails.root}/public/resources/jingdong/project_id/download/a.txt"
  #
  #   fa.download(
  #     :dir,
  #     project_id: 'project_id',
  #     date:       '2015-05-01',
  #     direction:  'download'
  #    )
  #   # from server-side  "/home/jingdong/download/20150501"
  #   # to local-side     "#{Rails.root}/public/resources/jingdong/project_id/download"
  #
  # Returns an Array of files.
  def download(type, args)
    from, to = download_server_path(args), download_local_path(args)

    self.files = ::SftpProxy.download(type, from, to)
  end

  def upload(type, args)
    from, to = upload_local_path(args), upload_server_path(args)

    ::SftpProxy.upload(type, from, to)
  end

  def names
    files.map(&:basename).map(&:to_s).map{|fn| NameMapping.parse(organization, fn)}
  end

  def links
    files.map(&:to_s).map{|fn| fn.gsub( File.join(Rails.root.to_s,'public'), '')}
  end

  private


    def download_server_path(args)
      assert_present_keys(args, :date, :direction)

      direction, file = args.values_at(:direction, :file)
      date = args.fetch(:date, Date.today.to_s).gsub('-', '')

      "/home/#{organization}/#{direction}/#{date}/#{file}"
    end

    def download_local_path(args)
      assert_present_keys(args, :direction, :project_id)

      direction, project_id = args.values_at(:direction, :project_id)
      to_dir = Pathname.new File.join(Rails.root, "public", "resources", organization.to_s, project_id, direction.to_s)
      to_dir.mkpath

      to_dir.to_s
    end

    def upload_server_path(args)
      date = args.fetch(:date, Date.today.to_s).gsub('-', '')
      "/home/#{args[:organization]}/download/#{date}"
    end

    def upload_local_path(args)
      args[:file]
    end

    def assert_present_keys(ha, *keys)
      keys.each{|k| ha.fetch(k){ raise "No #{k} passed." }}
    end

end
