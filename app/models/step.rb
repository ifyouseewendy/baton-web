class Step
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  # References
  belongs_to :task
  has_many :files, foreign_key: 'step_id', class_name: 'AttachFile', dependent: :destroy

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String
  field :job_id,      :type => String
  field :result,      :type => Hash

  def stage
    task.stage
  end

  def project
    stage.project
  end

  def recipe
    project.recipe
  end

  def run(args)
    job = "#{recipe.capitalize}Job::Step#{job_id}".constantize.new
    data = job.run self, args.merge({
      project_id: project.id.to_s,
    })

    self.update_attribute(:result, data)

    if data[:status] == :succeed
      self.done!
    else
      self.undone!
    end
  end

  def file_list_date
    return Date.today.to_s if result.blank? or result[:status].to_sym == :failed

    result[:query][:date]
  end

  def add_file(filename, platform, options = {})
    af = AttachFile.create(step: self, file: File.open(filename), platform: platform)
    unless options[:override]
      self.files << af
    else
      self.files = Array.wrap(af)
    end
  end

  def file_names
    files.map(&:file_identifier)
  end

  def file_urls
    files.map(&:file_url)
  end

end
