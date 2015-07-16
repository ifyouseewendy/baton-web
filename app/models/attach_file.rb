class AttachFile
  include Mongoid::Document
  include Mongoid::Timestamps

  # References
  belongs_to :step

  # Hooks
  before_destroy ->{ self.remove_file! }

  # Fields
  field :organization, :type => Symbol # Project's bourse or platform

  mount_uploader :file, FileUploader

  def store_dir
    # Use download directory to be consistant with file structure on FTP
    "resources/#{organization_name}/#{project.id}/download"
  end

  def recipe
    step.try(:recipe) || raise("You need to set Step relation first")
  end

  def project
    step.try(:project) || raise("You need to set Step relation first")
  end

  def organization_name
    step.env == :test ? "#{organization}_test" : "#{organization}"
  end

end
