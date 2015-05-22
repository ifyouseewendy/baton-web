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
    begin
      job = "#{recipe.capitalize}Job::Step#{job_id}".constantize.new
      data = job.run self, args.merge({
        project_id: project.id.to_s,
      })

      self.update_attribute(:result, data)
      self.done! if data[:status] == :succeed
    rescue => e
      self.update_attribute(:result, {status: :failed, message: e.message} )
    end
  end

  def file_list_date
    return Date.today.to_s if result.blank?

    result[:query][:date]
  end

  def add_file(filename)
    self.files << AttachFile.create(step: self, file: File.open(filename))
  end

end
