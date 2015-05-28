class AttachFile
  include Mongoid::Document
  include Mongoid::Timestamps

  # References
  belongs_to :step

  # Fields
  field :platform, :type => Symbol

  mount_uploader :file, FileUploader

  def store_dir
    "resources/#{platform}/#{project.id}/upload"
  end

  def recipe
    step.try(:recipe) || raise("You need to set Step relation first")
  end

  def project
    step.try(:project) || raise("You need to set Step relation first")
  end
end
